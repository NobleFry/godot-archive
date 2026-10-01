# 走路视角摇晃（Head Bob）实现教程

## 概述

Head Bob 是第一人称游戏中常见的相机效果，通过模拟行走时头部的自然晃动来增强沉浸感。本教程基于 Godot 4.6 实现，支持根据玩家状态（静止/走路/冲刺/空中）自动调整摇晃幅度。

## 架构

在 `CameraPivot` 和 `Camera3D` 之间插入一个 `HeadBob` 节点，挂载独立脚本：

```
Player (CharacterBody3D)
  └─ CameraPivot (Node3D)     ← 控制俯仰
       └─ HeadBob (Node3D)    ← 新增：视角摇晃
            ├─ Camera3D
            └─ AudioListener3D
```

这样 HeadBob 的位移和旋转只影响相机，不会干扰 CameraPivot 的俯仰逻辑。

## 第一步：创建 HeadBob 脚本

新建 `scripts/actors/head_bob.gd`：

```gdscript
extends Node3D

## 走路摇晃参数
@export_group("Walk Bob")
@export var walk_bob_y: float = 0.035       # Y轴位移振幅（米）
@export var walk_bob_x: float = 1.5         # X轴旋转振幅（度）
@export var walk_bob_freq: float = 10.0     # 摇晃频率

## 冲刺摇晃参数
@export_group("Sprint Bob")
@export var sprint_bob_y: float = 0.055
@export var sprint_bob_x: float = 2.5
@export var sprint_bob_freq: float = 14.0

## 过渡参数
@export_group("Smoothing")
@export var smoothing_speed: float = 10.0   # 状态切换时的平滑速度

var _time: float = 0.0
var _current_bob_y: float = 0.0
var _current_bob_x: float = 0.0
var _current_freq: float = 0.0


func update(horizontal_speed: float, on_floor: bool, is_sprinting: bool) -> void:
	# 确定目标参数
	var target_y: float
	var target_x: float
	var target_freq: float

	if not on_floor or horizontal_speed < 0.5:
		# 空中或静止 → 不摇晃
		target_y = 0.0
		target_x = 0.0
		target_freq = 0.0
	elif is_sprinting:
		target_y = sprint_bob_y
		target_x = sprint_bob_x
		target_freq = sprint_bob_freq
	else:
		target_y = walk_bob_y
		target_x = walk_bob_x
		target_freq = walk_bob_freq

	# 平滑过渡到目标值
	var delta = get_physics_process_delta_time()
	_current_bob_y = move_toward(_current_bob_y, target_y, smoothing_speed * delta)
	_current_bob_x = move_toward(_current_bob_x, target_x, smoothing_speed * delta)
	_current_freq = move_toward(_current_freq, target_freq, smoothing_speed * delta)

	# 累积时间
	if _current_freq > 0.0:
		_time += delta * _current_freq

	# 应用摇晃
	position.y = sin(_time) * _current_bob_y
	rotation.x = sin(_time) * deg_to_rad(_current_bob_x)
```

### 关键点说明

| 概念 | 说明 |
|------|------|
| `sin(_time)` | 正弦波驱动，产生自然的周期性晃动 |
| `move_toward` | 平滑插值，状态切换时不会突变 |
| `_time` 累积 | 频率越高，`_time` 增长越快，摇晃越急促 |
| `horizontal_speed < 0.5` | 避免极慢移动时也触发摇晃 |
| X轴旋转用 `deg_to_rad` | export 给用户的是度数，Godot 内部用弧度 |

## 第二步：修改 player.gd

在 `player.gd` 中添加对 HeadBob 的引用和调用。

### 添加节点引用（在现有 `@onready` 区域）：

```gdscript
@onready var head_bob: Node3D = $CameraPivot/HeadBob
```

### 在 `_physics_process` 的 `move_and_slide()` 之后调用：

```gdscript
move_and_slide()

# Head Bob
var h_speed := Vector2(velocity.x, velocity.z).length()
head_bob.update(h_speed, is_on_floor(), Input.is_action_pressed("sprint"))
```

> 传递水平速度让 HeadBob 判断是否在移动，传递 `is_on_floor()` 和冲刺状态来决定摇晃模式。

## 第三步：修改场景树

在 `player.tscn` 中，在 `CameraPivot` 和 `Camera3D` 之间插入 `HeadBob` 节点。

**方式一：在 Godot 编辑器中操作（推荐）**

1. 打开 `scenes/actors/player.tscn`
2. 在 Scene 面板中右键 `CameraPivot` → 添加子节点 → 选择 `Node3D`
3. 将其重命名为 `HeadBob`
4. 将 `Camera3D` 和 `AudioListener3D` 拖拽到 `HeadBob` 下（成为其子节点）
5. 选中 `HeadBob` 节点，在 Inspector 中挂载 `scripts/actors/head_bob.gd`

**方式二：手动编辑 .tscn 文件**

将 `player.tscn` 中 CameraPivot 下的节点改为：

```tscn
[node name="CameraPivot" type="Node3D" parent="." unique_id=422224338]

[node name="HeadBob" type="Node3D" parent="CameraPivot"]
script = ExtResource("head_bob_script_id")

[node name="Camera3D" type="Camera3D" parent="CameraPivot/HeadBob" unique_id=1705642495]

[node name="AudioListener3D" type="AudioListener3D" parent="CameraPivot/HeadBob" unique_id=866496573]
```

> 注意：如果手动编辑，需要先添加 `[ext_resource type="Script" path="res://scripts/actors/head_bob.gd" id="..."]`，然后用对应的 id。

## 参数调优参考

| 参数 | 效果 | 建议范围 |
|------|------|---------|
| `walk_bob_y` | 走路时上下晃动幅度 | 0.02 ~ 0.06 |
| `walk_bob_x` | 走路时前后点头幅度（度） | 0.5 ~ 3.0 |
| `walk_bob_freq` | 走路摇晃频率 | 8 ~ 12 |
| `sprint_bob_y` | 冲刺上下晃动幅度 | 0.04 ~ 0.08 |
| `sprint_bob_x` | 冲刺前后点头幅度（度） | 1.5 ~ 4.0 |
| `sprint_bob_freq` | 冲刺摇晃频率 | 12 ~ 18 |
| `smoothing_speed` | 状态切换过渡速度 | 5 ~ 15 |

## 扩展思路

- **蹲下摇晃**：在 `update()` 中增加 crouch 参数，设定蹲下的低频小幅摇晃
- **呼吸摇摆**：静止时用极低频率的微弱摇晃模拟呼吸
- **着陆冲击**：落地时用一次性的 `Tween` 动画做相机下压反弹
- **FOV 呼吸**：冲刺时配合 FOV 增大，增强速度感
