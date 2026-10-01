# 玩家/无人机架构教程 + 示例代码（不修改现有代码）

> 本文是**架构教程与示例代码**，不会直接改动项目脚本。示例代码仅用于说明思路，请按需整合到你的实际结构中。

## 1. 现有架构速览（对照你项目中的实现）

### 视图/模式管理

- `ViewStateManager` 已有三种视图：FIRST_PERSON / THIRD_PERSON_DRONE / FREE_DRONE。
- 位置：`src/actors/player/components/view_state_manager.gd:6-25`

### 相机控制

- `CameraController` 在第一/第三人称时处理鼠标旋转，并根据视图切换相机。
- 位置：`src/actors/player/components/camera_controller.gd:32-93`

### 输入路由

- `PlayerInputController` 在 FREE_DRONE 下禁用逻辑输入（玩家不再移动/战斗）。
- 位置：`src/actors/player/components/player_input_controller.gd:44-83`

### 无人机主体

- `Drone` 具备 `State` 枚举（FOLDED/FOLLOW/FREE/STANDBY）但当前主要逻辑在 `drone.gd`。
- 位置：`src/actors/player/components/drone/drone.gd:4-169`

---

## 2. 目标模式设计（满足你的需求）

### 四种无人机模式（建议以 DroneState 承载）

1. **FIRST_PERSON（第一人称）**

   - 无人机隐藏/停用
   - 玩家正常输入与相机
2. **THIRD_PERSON_FOLLOW（第三人称跟随）**

   - 替换玩家原第三人称
   - 鼠标**只控制相机**，不改变玩家朝向
3. **FREE_FLIGHT（自由飞行）**

   - 玩家逻辑输入禁用
   - 无人机完全自由操控
4. **STANDBY（待机）**

   - 切回第一人称时记录当前位置为待机点
   - 低耗电，随时可恢复到之前模式

### 切换约束（你已确认）

- 距离：**2 米内**
- 无障碍：**玩家到无人机射线无阻挡**

---

## 3. 输入映射建议（可直接放入 Input Map）

- `change_view`：第一人称 ↔ 第三人称（仅玩家视图）
- `deploy_drone`：第一人称 ↔ 最近一次无人机模式
- **新增** `drone_mode_toggle`：THIRD_PERSON_FOLLOW ↔ FREE_FLIGHT

> 这样不会打乱你现有的 `change_view` / `deploy_drone` 逻辑。

---

## 4. 完整示例架构（可直接参考的“完整示例”）

> **说明**：以下示例是“完整结构范例”，便于你拷贝改写。**每段代码都标注了文件路径**。仍需根据你项目的节点路径/信号命名适配。

### 4.1 目录结构建议
```
Drone
 ├─ Drone.gd
 ├─ DroneCamera (Camera3D)
 ├─ BatteryComponent
 └─ States
     ├─ DroneState.gd
     ├─ FirstPersonState.gd
     ├─ ThirdPersonFollowState.gd
     ├─ FreeFlightState.gd
     └─ StandbyState.gd
```

### 4.2 Drone.gd（完整示例）
**路径**：`src/actors/player/components/drone/Drone.gd`
```gdscript
extends CharacterBody3D
class_name Drone

enum DroneMode {
    FIRST_PERSON,
    THIRD_PERSON_FOLLOW,
    FREE_FLIGHT,
    STANDBY
}

@export var max_switch_distance := 2.0
@export var follow_offset := Vector3(0, 1.5, -0.5)
@export var low_drain_multiplier := 0.2
@export var follow_drain_multiplier := 0.7

@onready var drone_camera: Camera3D = $DroneCamera
@onready var battery: BatteryComponent = $BatteryComponent
@onready var state_root: Node = $States

@onready var states := {
    DroneMode.FIRST_PERSON: state_root.get_node("FirstPersonState"),
    DroneMode.THIRD_PERSON_FOLLOW: state_root.get_node("ThirdPersonFollowState"),
    DroneMode.FREE_FLIGHT: state_root.get_node("FreeFlightState"),
    DroneMode.STANDBY: state_root.get_node("StandbyState"),
}

var current_mode: int = DroneMode.FIRST_PERSON
var last_active_mode: int = DroneMode.THIRD_PERSON_FOLLOW
var standby_position: Vector3

var player: CharacterBody3D

func _ready():
    player = get_tree().get_first_node_in_group("player") as CharacterBody3D
    if not player:
        push_warning("Player not found in group: player")

    for s in states.values():
        s.drone = self
        s.player = player

    enter_mode(DroneMode.FIRST_PERSON)

# --- 模式切换入口 ---
func request_switch(target_mode: int) -> void:
    if not can_switch_mode():
        return
    enter_mode(target_mode)

func enter_mode(target_mode: int) -> void:
    if states.has(current_mode):
        states[current_mode].exit()

    if target_mode != DroneMode.FIRST_PERSON:
        last_active_mode = target_mode

    current_mode = target_mode
    states[current_mode].enter()

# --- 通用约束 ---
func can_switch_mode() -> bool:
    if not player:
        return false

    if player.global_position.distance_to(global_position) > max_switch_distance:
        return false

    var space_state = get_world_3d().direct_space_state
    var query := PhysicsRayQueryParameters3D.create(
        player.global_position,
        global_position
    )
    query.exclude = [player, self]

    var hit = space_state.intersect_ray(query)
    return hit.is_empty()

# --- 便捷入口（用于输入映射） ---
func toggle_deploy():
    if current_mode == DroneMode.FIRST_PERSON:
        enter_mode(last_active_mode)
    else:
        enter_mode(DroneMode.FIRST_PERSON)

func toggle_follow_free():
    if current_mode == DroneMode.THIRD_PERSON_FOLLOW:
        enter_mode(DroneMode.FREE_FLIGHT)
    elif current_mode == DroneMode.FREE_FLIGHT:
        enter_mode(DroneMode.THIRD_PERSON_FOLLOW)
```

### 4.3 DroneState.gd（基类）
**路径**：`src/actors/player/components/drone/states/DroneState.gd`
```gdscript
extends Node
class_name DroneState

var drone: Drone
var player: Player

func enter() -> void: pass
func exit() -> void: pass
func handle_input(_event: InputEvent) -> void: pass
func physics_update(_delta: float) -> void: pass
```

### 4.3.1 BatteryComponent.gd（新增耗电倍率字段，方案 A）
**路径**：`src/actors/player/components/drone/battery_component.gd`
```gdscript
extends Node
class_name BatteryComponent

signal battery_depleted
signal battery_changed(current_percentage)

@export_group("Battery Capacity")
@export var max_battery: float = 100.0
@export var base_drain_rate: float = 0.5
@export var scan_drain: float = 15.0

# 新增：耗电倍率
@export var drain_multiplier: float = 1.0

var current_battery: float
var is_draining: bool = false

func _ready() -> void:
    current_battery = max_battery

func _process(delta: float) -> void:
    if is_draining and current_battery > 0:
        drain(base_drain_rate * drain_multiplier * delta)

func set_drain_multiplier(value: float) -> void:
    drain_multiplier = maxf(0.0, value)

func start_draining() -> void:
    is_draining = true

func stop_draining() -> void:
    is_draining = false

func drain(amount: float) -> void:
    if current_battery <= 0.0:
        return

    current_battery -= amount
    current_battery = maxf(0.0, current_battery)
    battery_changed.emit(current_battery / max_battery)

    if current_battery <= 0.0:
        is_draining = false
        battery_depleted.emit()

func recharge(amount: float) -> void:
    current_battery += amount
    current_battery = minf(max_battery, current_battery)
    battery_changed.emit(current_battery / max_battery)
```

### 4.4 FirstPersonState.gd（隐藏/停用）
**路径**：`src/actors/player/components/drone/states/FirstPersonState.gd`
```gdscript
extends DroneState

func enter() -> void:
    drone.visible = false
    drone.set_physics_process(false)
    drone.set_process_unhandled_input(false)
    drone.velocity = Vector3.ZERO

    if drone.battery:
        drone.battery.stop_draining()
```

### 4.5 ThirdPersonFollowState.gd（第三人称跟随）
**路径**：`src/actors/player/components/drone/states/ThirdPersonFollowState.gd`
```gdscript
extends DroneState

func enter() -> void:
    drone.visible = true
    drone.set_physics_process(true)
    drone.set_process_unhandled_input(false)

    if drone.battery:
        drone.battery.set_drain_multiplier(drone.follow_drain_multiplier)
        drone.battery.start_draining()

func physics_update(_delta: float) -> void:
    if not player:
        return
    var target = player.global_position + drone.follow_offset
    drone.global_position = target
```

### 4.6 FreeFlightState.gd（自由飞行）
**路径**：`src/actors/player/components/drone/states/FreeFlightState.gd`
```gdscript
extends DroneState

@export var max_speed := 8.0
@export var acceleration := 12.0
@export var friction := 8.0
@export var mouse_sensitivity := 0.002

func enter() -> void:
    drone.visible = true
    drone.set_physics_process(true)
    drone.set_process_unhandled_input(true)
    if drone.battery:
        drone.battery.set_drain_multiplier(1.0)
        drone.battery.start_draining()

func exit() -> void:
    drone.velocity = Vector3.ZERO

func handle_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        drone.rotate_y(-event.relative.x * mouse_sensitivity)
        drone.drone_camera.rotate_x(-event.relative.y * mouse_sensitivity)
        drone.drone_camera.rotation.x = clamp(drone.drone_camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func physics_update(delta: float) -> void:
    var input_dir = Input.get_vector("left", "right", "forward", "back")
    var move_up_down = Input.get_axis("down", "up")

    var cam_basis = drone.drone_camera.global_transform.basis
    var horizontal_direction = (cam_basis.x * input_dir.x + cam_basis.z * input_dir.y)
    horizontal_direction.y = 0
    horizontal_direction = horizontal_direction.normalized()

    if horizontal_direction or move_up_down != 0:
        drone.velocity.x = move_toward(drone.velocity.x, horizontal_direction.x * max_speed, acceleration * delta)
        drone.velocity.z = move_toward(drone.velocity.z, horizontal_direction.z * max_speed, acceleration * delta)
        drone.velocity.y = move_toward(drone.velocity.y, move_up_down * max_speed, acceleration * delta)
    else:
        drone.velocity.x = move_toward(drone.velocity.x, 0, friction * delta)
        drone.velocity.y = move_toward(drone.velocity.y, 0, friction * delta)
        drone.velocity.z = move_toward(drone.velocity.z, 0, friction * delta)

    drone.move_and_slide()
```

### 4.7 StandbyState.gd（待机 + 低耗电）
**路径**：`src/actors/player/components/drone/states/StandbyState.gd`
```gdscript
extends DroneState

func enter() -> void:
    drone.visible = true
    drone.set_physics_process(false)
    drone.set_process_unhandled_input(false)

    drone.standby_position = drone.global_position

    if drone.battery:
        drone.battery.set_drain_multiplier(drone.low_drain_multiplier)
        drone.battery.start_draining()

func exit() -> void:
    if drone.battery:
        drone.battery.set_drain_multiplier(1.0)
```

### 4.8 输入与视角的“适配示例”
**路径**：`src/actors/player/components/player_input_controller.gd`
```gdscript
# 顶部新增信号
signal drone_mode_toggle_requested

# 放在“系统和元输入”区块中（deploy_drone 之后）
if event.is_action_pressed("drone_mode_toggle"):
    drone_mode_toggle_requested.emit()
    return

# 仅发信号，不在 InputController 内部调用 drone（解耦方案）
# 连接信号（示例：在 Drone / CameraController 中）
# player_input_controller.drone_mode_toggle_requested.connect(_on_drone_mode_toggle_requested)

# Drone 中的接收与连接示例（推荐）
# 在 Drone._ready() 里（组查找版）：
# var input_ctrl = get_tree().get_first_node_in_group("player_input")
# if input_ctrl:
#     input_ctrl.drone_mode_toggle_requested.connect(_on_drone_mode_toggle_requested)
#     input_ctrl.drone_deploy_requested.connect(_on_drone_deploy_requested)
#
# func _on_drone_mode_toggle_requested():
#     toggle_follow_free()
#
# func _on_drone_deploy_requested():
#     toggle_deploy()

# deploy_drone 保持“返回上一模式”语义
if event.is_action_pressed("deploy_drone"):
    drone_deploy_requested.emit()
    return
```

---

## 5. 视角与输入控制的关键点

### 第三人称跟随：鼠标不转玩家朝向

- 你已有相机在 `camera_controller.gd` 中的旋转逻辑。
- 只需确保 **第三人称时鼠标只转相机**，而不调用玩家旋转。
- 参考现有逻辑：`camera_controller.gd:32-41`（第一人称旋转玩家，第三人称旋转相机）

**示例：相机控制中区分第一/第三人称**
**路径**：`src/actors/player/components/camera_controller.gd`
```gdscript
func _on_camera_moved(rot_x: float, rot_y: float) -> void:
    if view_state_manager.current_state == ViewStateManager.State.FIRST_PERSON:
        # 第一人称：转玩家
        player.rotate_y(-rot_x * sensitivity)
        camera_pivot.rotate_x(-rot_y * sensitivity)
    elif view_state_manager.current_state == ViewStateManager.State.THIRD_PERSON_DRONE:
        # 第三人称跟随：只转相机
        camera_pivot.rotate_y(-rot_x * sensitivity)
        camera_pivot.rotate_x(-rot_y * sensitivity)

    camera_pivot.rotation.x = clamp(
        camera_pivot.rotation.x,
        deg_to_rad(tilt_lower_limit),
        deg_to_rad(tilt_upper_limit)
    )
```

### 自由飞行：禁用玩家逻辑输入

- 现有做法：`player_input_controller.gd:81-83` 在 FREE_DRONE 时禁用逻辑输入。
- 建议继续沿用该模式。

**示例：视图切换时禁用逻辑输入**
**路径**：`src/actors/player/components/player_input_controller.gd`
```gdscript
func _on_view_state_changed(new_state: int) -> void:
    is_logic_input_active = (new_state != ViewStateManager.State.FREE_DRONE)
```

---

## 6. 推荐的状态组织方式（结构示意）

```
Drone
 ├─ StateMachine
 │   ├─ FirstPersonState   (隐藏/停用)
 │   ├─ ThirdPersonFollow  (跟随+相机)
 │   ├─ FreeFlightState    (自由操控)
 │   └─ StandbyState       (低耗电)
 └─ BatteryComponent
```

> 这样可以让“电量、约束、返回逻辑”都集中在无人机内部处理，便于扩展黑入功能等。

---

## 7. 验证清单（功能自测）

- [ ]  第一人称：无人机隐藏/停用，玩家正常控制
- [ ]  第三人称跟随：鼠标只控制相机，玩家朝向不被鼠标影响
- [ ]  自由飞行：玩家逻辑输入禁用，无人机可操控
- [ ]  切换第三 ↔ 自由仅在 2m 内且无遮挡时允许
- [ ]  从第三/自由回第一人称：无人机留在当前位置待机、低耗电、可随时返回

---

## 8. 未来扩展：黑入功能

建议在 DroneState 增加 `HACKING` 子状态，作为 FREE_FLIGHT 下的“行为分支”，避免破坏现有模式切换逻辑。

---

如果你想，我可以继续：

- 按你的实际命名/输入映射改写本教程
- 给出更贴合你现有脚本结构的版本（仍不改代码）
