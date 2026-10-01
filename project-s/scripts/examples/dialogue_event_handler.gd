extends Node
## 对话事件处理器示例
## 将此脚本挂载到任意节点，或作为 Autoload 单例使用

func _ready() -> void:
	# 监听对话内事件 (DialogueLine.event)
	DialogueManager.event_triggered.connect(_on_dialogue_event)

	# 监听对话完成事件
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.dialogue_marked_seen.connect(_on_dialogue_marked_seen)

	# 监听自定义事件 (DialogueEntry.trigger_event_on_complete)
	DialogueManager.custom_event_triggered.connect(_on_custom_event)


## 处理对话行内事件
func _on_dialogue_event(event_name: String) -> void:
	print("[DialogueEvent] ", event_name)

	match event_name:
		"quest_offer":
			print("  -> Quest offer presented to player")

		"quest_accepted_event":
			# 玩家接受了任务
			_start_ruins_quest()

		"chat_started":
			print("  -> Chat conversation started")


## 对话结束时触发
func _on_dialogue_ended() -> void:
	print("[Dialogue] Conversation ended")


## 对话被标记为已触发
func _on_dialogue_marked_seen(dialogue_id: String, npc_id: String) -> void:
	print("[Dialogue] Marked as seen: ", dialogue_id, " from NPC: ", npc_id)


## 自定义事件处理
func _on_custom_event(event_name: String) -> void:
	print("[CustomEvent] ", event_name)

	match event_name:
		"buddy_quest_started":
			_start_ruins_quest()


## 启动任务
func _start_ruins_quest() -> void:
	if not GameState.is_quest_active("ruins_investigation"):
		GameState.start_quest("ruins_investigation")
		print("[Quest] Started: ruins_investigation")

		# 给玩家一些初始物品
		GameState.add_item("compass", 1)
		print("[Item] Received: compass x1")
