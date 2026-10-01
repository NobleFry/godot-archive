class_name DialogueEntry extends Resource
## 对话条目资源类
## 组合对话资源、条件和优先级，表示一个可触发的对话条目

## 唯一标识符
@export var dialogue_id: String = ""

## 对话资源引用
@export var dialogue: DialogueResource

## 优先级 (数值越高越优先)
@export_range(-100, 100) var priority: int = 0

## 触发条件列表 (所有条件必须满足才能触发)
@export var conditions: Array[DialogueCondition] = []

## 对话完成时设置的标志位
@export var set_flags_on_complete: Dictionary = {}

## 对话完成时触发的事件
@export var trigger_event_on_complete: String = ""

## 是否只能触发一次
@export var one_shot: bool = false

## 最大触发次数 (0 = 无限制)
@export var max_trigger_count: int = 0

## 对话描述 (编辑器用途)
@export_multiline var description: String = ""

## 运行时: 已触发次数
var _trigger_count: int = 0


## 检查是否可以触发
func can_trigger() -> bool:
	# 检查是否已达到最大触发次数
	if max_trigger_count > 0 and _trigger_count >= max_trigger_count:
		return false

	# 检查 one_shot
	if one_shot and _trigger_count > 0:
		return false

	# 检查是否已触发过 (通过 GameState)
	if one_shot and not dialogue_id.is_empty():
		if GameState.has_seen_dialogue(dialogue_id):
			return false

	# 评估所有条件
	for condition: DialogueCondition in conditions:
		if condition == null:
			continue
		if not condition.evaluate():
			return false

	return true


## 对话完成时调用
func on_dialogue_complete(npc_id: String) -> void:
	_trigger_count += 1

	# 标记对话已触发
	if not dialogue_id.is_empty():
		GameState.mark_dialogue_seen(dialogue_id, npc_id)

	# 设置标志位
	for flag_name: String in set_flags_on_complete:
		GameState.set_flag(flag_name, set_flags_on_complete[flag_name])

	# 触发事件
	if not trigger_event_on_complete.is_empty():
		DialogueManager.trigger_custom_event(trigger_event_on_complete)


## 获取状态 (用于存档)
func get_state() -> Dictionary:
	return {
		"dialogue_id": dialogue_id,
		"trigger_count": _trigger_count
	}


## 恢复状态 (用于读档)
func restore_state(data: Dictionary) -> void:
	if data.get("dialogue_id", "") == dialogue_id:
		_trigger_count = data.get("trigger_count", 0)
