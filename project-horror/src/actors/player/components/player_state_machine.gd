# 状态机的管理器
# 持有当前激活状态并将godot的物理回调转发给该状态，它还负责执行状态间的切换

extends Node
class_name PlayerStateMachine

# 持有当前活跃的状态节点
var player: Player
var state: PlayerState

@export var initial_state: PlayerState

func _ready() -> void:
	await owner.ready

	player = owner

	for child in get_children():
		if child is PlayerState:
			# 自动建立引用关系
			child.state_machine = self
			child.player = player
	
	if initial_state:
		state = initial_state
	else:
		state = get_child(0)
	
	state.enter()

# 分发 将输入事件转发给当前状态
func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)

func _physics_process(delta: float) -> void:
	state.physics_update(delta)
	player.update_stature(player.is_crouching, delta)

func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	if not has_node(target_state_name):
		return
	state.exit()
	state = get_node(target_state_name)
	state.enter(msg)
