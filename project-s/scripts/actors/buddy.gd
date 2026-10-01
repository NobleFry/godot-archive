extends CharacterBody3D

## 对话注册组件 (管理多个对话)
@export var dialogue_registry: DialogueRegistry
## 交互角度 (度)
@export var interact_angle: float = 120.0

@onready var interaction_zone: Area3D = $InteractionZone

var _player_in_range: bool = false
var _player_ref: CharacterBody3D


func _ready() -> void:
	interaction_zone.body_entered.connect(_on_body_entered)
	interaction_zone.body_exited.connect(_on_body_exited)
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	# 如果没有手动指定 dialogue_registry，尝试从子节点获取
	if dialogue_registry == null:
		dialogue_registry = get_node_or_null("DialogueRegistry")


func _process(_delta: float) -> void:
	if _player_in_range and not DialogueManager.is_active():
		if _is_player_facing() and _is_npc_facing_player():
			InteractionPrompt.show_prompt()
		else:
			InteractionPrompt.hide_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _player_in_range and _player_ref:
		if not DialogueManager.is_active() and _is_player_facing() and _is_npc_facing_player():
			_trigger_dialogue()
			get_viewport().set_input_as_handled()


## 触发对话
func _trigger_dialogue() -> void:
	if dialogue_registry == null:
		return

	var dialogue := dialogue_registry.get_available_dialogue()
	if dialogue:
		var entry: DialogueEntry = dialogue_registry.get_current_entry()
		var d_id: String = entry.dialogue_id if entry else ""
		var n_id: String = dialogue_registry.npc_id
		DialogueManager.start_dialogue(dialogue, self, d_id, n_id)


func _is_player_facing() -> bool:
	if not _player_ref:
		return false
	var to_npc := (global_position - _player_ref.global_position).normalized()
	to_npc.y = 0
	to_npc = to_npc.normalized()
	var player_forward := -_player_ref.global_basis.z
	player_forward.y = 0
	player_forward = player_forward.normalized()
	var dot := player_forward.dot(to_npc)
	dot = clamp(dot, -1.0, 1.0)
	var angle := rad_to_deg(acos(dot))
	return angle <= interact_angle * 0.5


func _is_npc_facing_player() -> bool:
	if not _player_ref:
		return false
	# NPC→玩家 的方向向量 (水平面)
	var to_player := (_player_ref.global_position - global_position).normalized()
	to_player.y = 0
	to_player = to_player.normalized()
	# NPC 的前方向量 (水平面)
	var npc_forward := -global_basis.z
	npc_forward.y = 0
	npc_forward = npc_forward.normalized()
	# NPC 必须面向玩家 (前方半球范围)
	var dot := npc_forward.dot(to_player)
	return dot > 0.0  # dot > 0 表示角度 < 90°，即玩家在 NPC 前方


func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.name == "Player":
		_player_in_range = true
		_player_ref = body


func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D and body.name == "Player":
		_player_in_range = false
		_player_ref = null
		InteractionPrompt.hide_prompt()


func _on_dialogue_started(_npc: Node3D) -> void:
	InteractionPrompt.hide_prompt()


func _on_dialogue_ended() -> void:
	if _player_in_range and _is_player_facing() and _is_npc_facing_player():
		InteractionPrompt.show_prompt()
