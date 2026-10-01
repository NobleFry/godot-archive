extends Node

signal dialogue_started(npc: Node3D)
signal dialogue_ended
signal line_displayed(speaker: String, text: String)
signal choices_displayed(choices: Array[DialogueChoice])
signal event_triggered(event_name: String)
## 自定义事件触发信号
signal custom_event_triggered(event_name: String)
## 对话被标记为已触发信号
signal dialogue_marked_seen(dialogue_id: String, npc_id: String)

enum State { IDLE, TYPING, WAITING_FOR_INPUT, WAITING_FOR_CHOICE }
var current_state: State = State.IDLE

var _resource: DialogueResource
var _current_line: DialogueLine
var _visible_char_count: float = 0.0
var _full_text: String = ""

## 当前对话ID
var _dialogue_id: String = ""
## 当前NPC ID
var _npc_id: String = ""
## 当前NPC引用
var _npc_ref: Node3D = null

@export var type_speed: float = 30.0

func _process(delta: float) -> void:
	if current_state != State.TYPING:
		return
	_visible_char_count += type_speed * delta
	if _visible_char_count >= _full_text.length():
		_visible_char_count = float(_full_text.length())
		_on_type_finished()


func start_dialogue(resource: DialogueResource, npc: Node3D = null, dialogue_id: String = "", npc_id: String = "") -> void:
	_resource = resource
	_dialogue_id = dialogue_id
	_npc_id = npc_id
	_npc_ref = npc
	current_state = State.IDLE
	dialogue_started.emit(npc)
	_show_line(_resource.start_id)


func advance() -> void:
	match current_state:
		State.TYPING:
			_visible_char_count = float(_full_text.length())
			_on_type_finished()
		State.WAITING_FOR_INPUT:
			_advance_to_next()
		State.WAITING_FOR_CHOICE, State.IDLE:
			pass


func select_choice(index: int) -> void:
	if current_state != State.WAITING_FOR_CHOICE:
		return
	var choices: Array[DialogueChoice] = _current_line.choices
	if index < 0 or index >= choices.size():
		return
	_show_line(choices[index].next_id)


func get_visible_char_count() -> int:
	return int(_visible_char_count)


func is_active() -> bool:
	return current_state != State.IDLE


func _show_line(line_id: String) -> void:
	if line_id.is_empty():
		_end_dialogue()
		return
	if not _resource.lines.has(line_id):
		_end_dialogue()
		return
	_current_line = _resource.lines[line_id]
	_full_text = _current_line.text
	_visible_char_count = 0.0
	current_state = State.TYPING
	line_displayed.emit(_current_line.speaker, _full_text)
	if not _current_line.event.is_empty():
		event_triggered.emit(_current_line.event)


func _on_type_finished() -> void:
	if _current_line.choices.size() > 0:
		current_state = State.WAITING_FOR_CHOICE
		choices_displayed.emit(_current_line.choices)
	else:
		current_state = State.WAITING_FOR_INPUT


func _advance_to_next() -> void:
	var next := _current_line.next_id
	if next.is_empty():
		_end_dialogue()
	else:
		_show_line(next)


func _end_dialogue() -> void:
	# 对话历史记录由 DialogueRegistry/DialogueEntry 处理
	# 这里只发射信号通知
	if not _dialogue_id.is_empty():
		dialogue_marked_seen.emit(_dialogue_id, _npc_id)

	current_state = State.IDLE
	_resource = null
	_current_line = null
	_full_text = ""
	_visible_char_count = 0.0
	_dialogue_id = ""
	_npc_id = ""
	_npc_ref = null
	dialogue_ended.emit()


## 触发自定义事件
func trigger_custom_event(event_name: String) -> void:
	custom_event_triggered.emit(event_name)


## 获取当前对话ID
func get_current_dialogue_id() -> String:
	return _dialogue_id


## 获取当前NPC ID
func get_current_npc_id() -> String:
	return _npc_id


## 获取当前NPC引用
func get_current_npc() -> Node3D:
	return _npc_ref
