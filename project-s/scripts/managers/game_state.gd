extends Node
## 全局游戏状态管理单例 (Autoload)
## 管理 flags、quests、inventory、对话历史等游戏状态

## 标志位改变时触发
signal flag_changed(flag_name: String, new_value: Variant)
## 任务状态更新时触发
signal quest_updated(quest_id: String, status: String)
## 物品添加时触发
signal item_added(item_id: String, amount: int)
## 物品移除时触发
signal item_removed(item_id: String, amount: int)
## 对话被标记为已触发时触发
signal dialogue_seen(dialogue_id: String, npc_id: String)

## 通用标志位存储
var _flags: Dictionary = {}
## 任务状态: quest_id -> { status, progress, objectives }
var _quests: Dictionary = {}
## 物品栏: item_id -> amount
var _inventory: Dictionary = {}
## 对话历史: npc_id -> Array of dialogue_id
var _dialogue_history: Dictionary = {}
## 最后触发的对话ID
var _last_dialogue_id: String = ""
## 当前对话的NPC ID
var _current_npc_id: String = ""


# ============================================================
# Flag 操作
# ============================================================

## 设置标志位
func set_flag(flag_name: String, value: Variant) -> void:
	_flags[flag_name] = value
	flag_changed.emit(flag_name, value)


## 获取标志位值
func get_flag(flag_name: String, default: Variant = null) -> Variant:
	return _flags.get(flag_name, default)


## 检查标志位是否存在
func has_flag(flag_name: String) -> bool:
	return _flags.has(flag_name)


## 清除标志位
func clear_flag(flag_name: String) -> void:
	_flags.erase(flag_name)
	flag_changed.emit(flag_name, null)


## 设置布尔标志位 (便捷方法)
func set_bool(flag_name: String, value: bool = true) -> void:
	set_flag(flag_name, value)


## 检查布尔标志位是否为真 (便捷方法)
func is_true(flag_name: String) -> bool:
	return get_flag(flag_name, false) == true


## 递增数值标志位
func increment(flag_name: String, amount: int = 1) -> int:
	var current: int = get_flag(flag_name, 0)
	var new_value: int = current + amount
	set_flag(flag_name, new_value)
	return new_value


## 递减数值标志位
func decrement(flag_name: String, amount: int = 1) -> int:
	return increment(flag_name, -amount)


# ============================================================
# Quest 操作
# ============================================================

## 开始任务
func start_quest(quest_id: String) -> void:
	_quests[quest_id] = {
		"status": "active",
		"progress": 0,
		"objectives": {}
	}
	quest_updated.emit(quest_id, "active")


## 完成任务
func complete_quest(quest_id: String) -> void:
	if _quests.has(quest_id):
		_quests[quest_id]["status"] = "completed"
		quest_updated.emit(quest_id, "completed")


## 失败任务
func fail_quest(quest_id: String) -> void:
	if _quests.has(quest_id):
		_quests[quest_id]["status"] = "failed"
		quest_updated.emit(quest_id, "failed")


## 获取任务状态
func get_quest_status(quest_id: String) -> String:
	if _quests.has(quest_id):
		return _quests[quest_id]["status"]
	return "not_started"


## 检查任务是否进行中
func is_quest_active(quest_id: String) -> bool:
	return get_quest_status(quest_id) == "active"


## 检查任务是否已完成
func is_quest_completed(quest_id: String) -> bool:
	return get_quest_status(quest_id) == "completed"


## 设置任务进度
func set_quest_progress(quest_id: String, progress: int) -> void:
	if _quests.has(quest_id):
		_quests[quest_id]["progress"] = progress
		quest_updated.emit(quest_id, "progress")


## 获取任务进度
func get_quest_progress(quest_id: String) -> int:
	if _quests.has(quest_id):
		return _quests[quest_id].get("progress", 0)
	return 0


# ============================================================
# Inventory 操作
# ============================================================

## 添加物品
func add_item(item_id: String, amount: int = 1) -> void:
	var current: int = _inventory.get(item_id, 0)
	_inventory[item_id] = current + amount
	item_added.emit(item_id, amount)


## 移除物品
func remove_item(item_id: String, amount: int = 1) -> bool:
	var current: int = _inventory.get(item_id, 0)
	if current < amount:
		return false
	_inventory[item_id] = current - amount
	if _inventory[item_id] <= 0:
		_inventory.erase(item_id)
	item_removed.emit(item_id, amount)
	return true


## 检查是否拥有物品
func has_item(item_id: String, amount: int = 1) -> bool:
	return _inventory.get(item_id, 0) >= amount


## 获取物品数量
func get_item_count(item_id: String) -> int:
	return _inventory.get(item_id, 0)


# ============================================================
# 对话历史操作
# ============================================================

## 标记对话为已触发
func mark_dialogue_seen(dialogue_id: String, npc_id: String) -> void:
	if not _dialogue_history.has(npc_id):
		_dialogue_history[npc_id] = []
	if dialogue_id not in _dialogue_history[npc_id]:
		_dialogue_history[npc_id].append(dialogue_id)
	_last_dialogue_id = dialogue_id
	_current_npc_id = npc_id
	dialogue_seen.emit(dialogue_id, npc_id)


## 检查对话是否已触发过
func has_seen_dialogue(dialogue_id: String, npc_id: String = "") -> bool:
	if npc_id.is_empty():
		# 检查任意NPC是否触发过此对话
		for npc_dialogues: Array in _dialogue_history.values():
			if dialogue_id in npc_dialogues:
				return true
		return false
	return _dialogue_history.has(npc_id) and dialogue_id in _dialogue_history[npc_id]


## 获取特定NPC的对话历史
func get_npc_dialogue_history(npc_id: String) -> Array:
	return _dialogue_history.get(npc_id, [])


## 获取最后触发的对话ID
func get_last_dialogue_id() -> String:
	return _last_dialogue_id


## 获取当前NPC ID
func get_current_npc_id() -> String:
	return _current_npc_id


# ============================================================
# 序列化 (存档/读档支持)
# ============================================================

## 序列化所有状态
func serialize() -> Dictionary:
	return {
		"flags": _flags.duplicate(),
		"quests": _quests.duplicate(true),
		"inventory": _inventory.duplicate(),
		"dialogue_history": _dialogue_history.duplicate(true),
		"last_dialogue_id": _last_dialogue_id,
		"current_npc_id": _current_npc_id
	}


## 反序列化状态
func deserialize(data: Dictionary) -> void:
	_flags = data.get("flags", {})
	_quests = data.get("quests", {})
	_inventory = data.get("inventory", {})
	_dialogue_history = data.get("dialogue_history", {})
	_last_dialogue_id = data.get("last_dialogue_id", "")
	_current_npc_id = data.get("current_npc_id", "")


## 重置所有状态
func reset() -> void:
	_flags.clear()
	_quests.clear()
	_inventory.clear()
	_dialogue_history.clear()
	_last_dialogue_id = ""
	_current_npc_id = ""
