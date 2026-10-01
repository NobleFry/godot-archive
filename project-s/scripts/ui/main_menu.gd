extends Control
## 开始菜单
## 提供"开始游戏"和"退出游戏"选项

## 开始游戏后加载的场景
@export_file("*.tscn") var game_scene: String = "res://scenes/levels/test.tscn"

@onready var start_button: Button = $CenterContainer/PanelContainer/VBoxContainer/StartButton
@onready var quit_button: Button = $CenterContainer/PanelContainer/VBoxContainer/QuitButton


func _ready() -> void:
	# 菜单需要鼠标可见可点击
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	# 默认聚焦开始按钮，支持键盘/手柄导航
	start_button.grab_focus()


func _on_start_pressed() -> void:
	# 重置全局状态，确保新游戏从干净状态开始
	GameState.reset()
	get_tree().change_scene_to_file(game_scene)


func _on_quit_pressed() -> void:
	get_tree().quit()
