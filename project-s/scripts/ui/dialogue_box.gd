extends Control

@onready var speaker_label: Label = $PanelContainer/VBoxContainer/SpeakerLabel
@onready var text_label: RichTextLabel = $PanelContainer/VBoxContainer/TextLabel
@onready var choices_container: VBoxContainer = $PanelContainer/VBoxContainer/ChoicesContainer

func _ready() -> void:
	visible = false
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.line_displayed.connect(_on_line_displayed)
	DialogueManager.choices_displayed.connect(_on_choices_displayed)


func _process(_delta: float) -> void:
	if not visible:
		return
	if DialogueManager.current_state == DialogueManager.State.TYPING:
		var total := maxf(float(text_label.get_total_character_count()), 1.0)
		text_label.visible_ratio = float(DialogueManager.get_visible_char_count()) / total
	elif DialogueManager.current_state != DialogueManager.State.IDLE:
		text_label.visible_ratio = 1.0


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if DialogueManager.current_state == DialogueManager.State.WAITING_FOR_CHOICE:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		DialogueManager.advance()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_viewport().set_input_as_handled()
		DialogueManager.advance()


func _on_dialogue_started(_npc: Node3D) -> void:
	visible = true
	_clear_choices()


func _on_dialogue_ended() -> void:
	visible = false
	speaker_label.text = ""
	speaker_label.visible = false
	text_label.text = ""
	text_label.visible_ratio = 1.0
	_clear_choices()


func _on_line_displayed(speaker: String, _text: String) -> void:
	speaker_label.text = speaker
	speaker_label.visible = not speaker.is_empty()
	text_label.text = _text
	text_label.visible_ratio = 0.0
	_clear_choices()


func _on_choices_displayed(choices: Array[DialogueChoice]) -> void:
	_clear_choices()
	for i in range(choices.size()):
		var choice: DialogueChoice = choices[i]
		var button := Button.new()
		button.text = choice.text
		button.pressed.connect(func(): DialogueManager.select_choice(i))
		choices_container.add_child(button)
	choices_container.visible = true


func _clear_choices() -> void:
	for child in choices_container.get_children():
		child.queue_free()
	choices_container.visible = false
