# Godot 4.6 简单第一人称移动教程（含跳跃/冲刺/真实蹲伏）

> 说明：本文仅提供教程与示例代码，不会直接修改你的项目文件。请按步骤在编辑器中操作。

## 0. 前置与目录约定
- **Godot 版本**：4.6（与你的项目一致）
- **玩家场景**：`res://scenes/actors/player.tscn`
- **脚本目录**：`res://scripts/actors/`

本教程采用 **Player + CameraPivot** 结构，便于区分水平旋转（yaw）与俯仰（pitch），并支持“真实蹲伏”。

---

## 1. 调整玩家场景结构
打开 `res://scenes/actors/player.tscn`：

在 `Player (CharacterBody3D)` 下面新增节点：
```
Player (CharacterBody3D)
├─ CollisionShape3D
├─ MeshInstance3D
└─ CameraPivot (Node3D)
   └─ Camera3D
```

- `CameraPivot` 用于控制俯仰（pitch）
- `Player` 本体控制水平旋转（yaw）

> 如果你之后要做头部摆动/武器/交互射线，都可以挂在 `CameraPivot` 或 `Camera3D` 下。

---

## 2. 添加输入映射（Project Settings）
在 **Project > Project Settings > Input Map** 添加：

| Action | 键位 |
|---|---|
| `move_forward` | W |
| `move_back` | S |
| `move_left` | A |
| `move_right` | D |
| `jump` | Space |
| `sprint` | Shift |
| `crouch` | Ctrl 或 C |
| `toggle_mouse` | Esc 或 Tab |

---

## 3. 新建玩家脚本 `Player.gd`
在 `res://scripts/actors/` 创建 `Player.gd`，并挂到 `Player` 节点。

> **提示**：脚本里使用 `@onready` 获取 `CameraPivot` 和 `CollisionShape3D`。

### 完整示例（可直接粘贴）
```gdscript
extends CharacterBody3D

@export var walk_speed := 4.5
@export var sprint_speed := 7.5
@export var jump_velocity := 4.5
@export var mouse_sensitivity := 0.12
@export var max_pitch_deg := 85.0  # 最大俯仰角（上下视角限制）

# 惯性/手感参数（方案 A）
@export var accel := 16.0            # 有输入时加速到目标速度
@export var ground_decel := 18.0     # 无输入时减速（地面）
@export var air_control := 4.0       # 空中控制强度

@export var stand_height := 1.8
@export var crouch_height := 1.2
@export var camera_stand_y := 0.7
@export var camera_crouch_y := 0.3

@onready var camera_pivot: Node3D = $CameraPivot
@onready var collider: CollisionShape3D = $CollisionShape3D

var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    _apply_capsule_height(stand_height)
    camera_pivot.position.y = camera_stand_y

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("toggle_mouse"):
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        else:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        return

    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        var yaw = -event.relative.x * mouse_sensitivity * 0.01
        var pitch = -event.relative.y * mouse_sensitivity * 0.01
        rotate_y(yaw)
        camera_pivot.rotate_x(pitch)
        camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-max_pitch_deg), deg_to_rad(max_pitch_deg))

func _physics_process(delta: float) -> void:
    # 重力
    if not is_on_floor():
        velocity.y -= gravity * delta

    # 跳跃
    if is_on_floor() and Input.is_action_just_pressed("jump"):
        velocity.y = jump_velocity

    # 移动输入
    var input_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

    var speed = walk_speed
    if Input.is_action_pressed("sprint"):
        speed = sprint_speed

    var direction = (transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()
    var target_vel = direction * speed

    if is_on_floor():
        if input_vec != Vector2.ZERO:
            velocity.x = move_toward(velocity.x, target_vel.x, accel * delta)
            velocity.z = move_toward(velocity.z, target_vel.z, accel * delta)
        else:
            velocity.x = move_toward(velocity.x, 0.0, ground_decel * delta)
            velocity.z = move_toward(velocity.z, 0.0, ground_decel * delta)
    else:
        # 空中给较弱的控制力
        velocity.x = move_toward(velocity.x, target_vel.x, air_control * delta)
        velocity.z = move_toward(velocity.z, target_vel.z, air_control * delta)

    # 蹲伏（真实：改变碰撞体 + 相机）
    if Input.is_action_pressed("crouch"):
        _apply_capsule_height(crouch_height)
        camera_pivot.position.y = camera_crouch_y
    else:
        _apply_capsule_height(stand_height)
        camera_pivot.position.y = camera_stand_y

    move_and_slide()

func _apply_capsule_height(h: float) -> void:
    if collider.shape is CapsuleShape3D:
        var capsule := collider.shape as CapsuleShape3D
        capsule.height = h
        # 将碰撞体下移一点，保持脚底对地面
        collider.position.y = h * 0.5
```

> **注意**：`mouse_sensitivity` 乘了 `0.01` 是为了将鼠标像素差转换为较合适的旋转量，可按手感调整。

#### 方案 A（惯性）调参建议
- `accel`：越大越“跟手”，越小越“滑”
- `ground_decel`：松手后刹车速度（越大停得越快）
- `air_control`：空中可控程度（通常低于地面）

---

## 4. 参数调优建议
- `walk_speed`：4.0 ~ 5.5
- `sprint_speed`：6.5 ~ 9.0
- `jump_velocity`：4.0 ~ 5.5
- `mouse_sensitivity`：0.08 ~ 0.18
- `stand_height` / `crouch_height`：1.8 / 1.2（与胶囊高度一致）
- `camera_stand_y` / `camera_crouch_y`：0.7 / 0.3（按角色身高微调）

---

## 5. 验证清单
- [ ] WASD 平面移动正常
- [ ] 鼠标水平/俯仰视角正常且不翻转
- [ ] 跳跃仅在地面可触发
- [ ] 冲刺速度切换正常
- [ ] 蹲伏时碰撞体高度与相机高度同步变化

---

## 6. 常见问题
**Q: 斜向移动更快？**
- 代码中已对输入向量做 `normalized()`，避免斜向加速。

**Q: 蹲伏后站起卡住？**
- 若头顶有障碍物，建议在“站起”前做一次 `RayCast3D` 或 `ShapeCast3D` 检测空间是否足够（可后续扩展）。

---

如果你希望我再补充 **交互射线**、**脚步声** 或 **头部摆动** 的章节，我可以在这份教程上继续扩展。