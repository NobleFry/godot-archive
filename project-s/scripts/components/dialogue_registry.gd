class_name DialogueRegistry extends Node
## NPC对话注册组件
## 挂载在NPC上，管理该NPC的所有对话条目，自动选择可触发的对话

## 对话被选中时触发
signal dialogue_selected(entry: DialogueEntry)
## 无可用对话时触发
signal no_dialogue_available

## NPC唯一标识符 (用于对话历史追踪)
@export var npc_id: String = ""

## 对话条目列表
@export var dialogue_entries: Array[DialogueEntry] = []

## 默认对话 (无任何条件满足时使用)
@export var fallback_dialogue: DialogueResource

## 是否在对话结束后重新检查可用对话
@export var recheck_after_dialogue: bool = true

## 当前选中的对话条目
var _current_entry: DialogueEntry = null
## 父节点引用
var _owner_node: Node3D = null


func _ready() -> void:
	_owner_node = get_parent() as Node3D
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	# 如果没有设置 npc_id，使用父节点名称
	if npc_id.is_empty() and _owner_node:
		npc_id = _owner_node.name


## 获取可用的对话资源
func get_available_dialogue() -> DialogueResource:
	_current_entry = _select_best_entry()

	if _current_entry:
		dialogue_selected.emit(_current_entry)
		return _current_entry.dialogue

	if fallback_dialogue:
		return fallback_dialogue

	no_dialogue_available.emit()
	return null


## 选择最佳对话条目
func _select_best_entry() -> DialogueEntry:
	var valid_entries: Array[DialogueEntry] = []

	for entry: DialogueEntry in dialogue_entries:
		if entry == null:
			continue
		if entry.can_trigger():
			valid_entries.append(entry)

	if valid_entries.is_empty():
		return null

	# 按优先级排序 (高优先级在前)
	valid_entries.sort_custom(
		func(a: DialogueEntry, b: DialogueEntry):
			return a.priority > b.priority
	)

	return valid_entries[0]


## 检查是否有可用对话
func has_available_dialogue() -> bool:
	return _select_best_entry() != null or fallback_dialogue != null


## 获取当前选中的条目
func get_current_entry() -> DialogueEntry:
	return _current_entry


## 对话结束处理
func _on_dialogue_ended() -> void:
	if _current_entry:
		_current_entry.on_dialogue_complete(npc_id)
		_current_entry = null


## 获取状态 (用于存档)
func get_state() -> Dictionary:
	var entries_state: Array = []
	for entry: DialogueEntry in dialogue_entries:
		if entry:
			entries_state.append(entry.get_state())
	return {
		"npc_id": npc_id,
		"entries": entries_state
	}


## 恢复状态 (用于读档)
func restore_state(data: Dictionary) -> void:
	if data.get("npc_id", "") != npc_id:
		return

	var entries_data: Array = data.get("entries", [])
	for i: int in range(min(entries_data.size(), dialogue_entries.size())):
		if dialogue_entries[i]:
			dialogue_entries[i].restore_state(entries_data[i])
