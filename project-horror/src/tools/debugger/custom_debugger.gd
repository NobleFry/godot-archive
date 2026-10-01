extends CanvasLayer

@onready var debug_root = $DebugRoot
@onready var fps_label = $DebugRoot/PanelContainer/VBoxContainer/FPSLabel

func _ready():
	debug_root.hide()
	if not OS.is_debug_build():
		set_process(false)
		set_process_input(false)

func _input(event):
	if event.is_action_pressed("toggle_debug"):
		debug_root.visible = !debug_root.visible

func _process(_delta):
	if debug_root.visible:
		fps_label.text = "FPS:" + str(Engine.get_frames_per_second())
		fps_label.text += "\nStatic Memory:" + String.humanize_size(OS.get_static_memory_usage())
