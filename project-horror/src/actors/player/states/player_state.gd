# 定义所有状态的通用接口，是所有具体状态的模板
# 基类

extends Node
class_name PlayerState

var player: Player
var state_machine: PlayerStateMachine

# 状态进入时调用（初始化动画，重置速度）
func enter(_msg := {}) -> void: pass

# 状态退出时调用（清理临时状态）
func exit() -> void: pass

# 在 _physics_process 中每帧调用，处理物理和状态机迁移
func physics_update(_delta: float) -> void: pass

# 处理瞬时按键事件
func handle_input(_event: InputEvent) -> void: pass

# 获取基于相机朝向的移动向量，减少子类重复代码
func get_move_direction() -> Vector3:
	var input_dir = player.input_controller.current_input_dir
	var camera_pivot = player.get_node("CameraPivot")

	# 将输入坐标转换为世界坐标系中的移动方向
	var dir = (camera_pivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	dir.y = 0
	return dir.normalized()
