extends CanvasLayer
## 游戏内暂停菜单
## ESC 打开/关闭；提供"继续游戏"和"返回主菜单"
## 作为 Autoload，存在于所有场景，但在主菜单场景中不响应

## 返回的主菜单场景
@export_file("*.tscn") var main_menu_scene: String = "res://scenes/ui/main_menu.tscn"

@onready var panel: Control = $Panel
@onready var resume_button: Button = $Panel/CenterContainer/PanelContainer/VBoxContainer/ResumeButton
@onready var menu_button: Button = $Panel/CenterContainer/PanelContainer/VBoxContainer/MenuButton

## 暂停前的鼠标模式，继续游戏时恢复（兼容对话中暂停的情况）
var _prev_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED


func _ready() -> void:
	# 暂停时本节点仍需运行，以处理输入和按钮点击
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false
	resume_button.pressed.connect(resume)
	menu_button.pressed.connect(_on_menu_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return
	# 主菜单场景下 ESC 不触发暂停
	if _is_main_menu():
		return
	get_viewport().set_input_as_handled()
	if get_tree().paused:
		resume()
	else:
		_pause()


## 当前是否处于主菜单场景
func _is_main_menu() -> bool:
	var scene := get_tree().current_scene
	return scene != null and scene.scene_file_path == main_menu_scene


func _pause() -> void:
	_prev_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	panel.visible = true
	resume_button.grab_focus()


## 继续游戏（按钮和 ESC 都会调用）
func resume() -> void:
	get_tree().paused = false
	panel.visible = false
	Input.mouse_mode = _prev_mouse_mode


func _on_menu_pressed() -> void:
	# 切场景前务必解除暂停，否则新场景也会处于暂停状态
	get_tree().paused = false
	# 隐藏面板：PauseMenu 是 autoload，不随场景切换销毁，否则会残留在主菜单上
	panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(main_menu_scene)
