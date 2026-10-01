# 处理并提供输入数据
# 输入源

extends Node
class_name PlayerInputController

# 移动相关信号
signal jump_pressed
signal sprint_pressed
signal sprint_released
signal crouch_toggled

# 视角与交互信号
signal camera_moved(rot_x: float, rot_y: float)
signal view_change_requested
signal drone_deploy_requested
signal drone_mode_toggle_requested
signal toggle_cursor_requested

# 战斗信号
signal attack_pressed
signal reload_pressed
signal change_weapon_next
signal change_weapon_prev

@export var current_input_dir: Vector2 = Vector2.ZERO
@export var is_input_active: bool = true
@export var is_logic_input_active: bool = true

@onready var view_state_manager: ViewStateManager = $"../ViewStateManager"

func _ready() -> void:
	if view_state_manager:
		view_state_manager.state_changed.connect(_on_view_state_changed)

	_on_view_state_changed(view_state_manager.current_state)

func _process(_delta: float) -> void:
	if not is_input_active:
		current_input_dir = Vector2.ZERO
		return

	current_input_dir = Input.get_vector("left", "right", "forward", "back")

	if not is_logic_input_active:
		current_input_dir = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if not is_input_active: return

	# --- 第一类：系统和元输入 ---
	if event.is_action_pressed("toggle_cursor"):
		toggle_cursor_requested.emit()
		return
	if event.is_action_pressed("deploy_drone"):
		drone_deploy_requested.emit()
		return
	if event.is_action_pressed("drone_mode_toggle"):
		drone_mode_toggle_requested.emit()
		return

	if not is_logic_input_active: return

	# --- 第二类：逻辑/战斗输入 (受 is_logic_input_active 控制) ---

	# 视角移动
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_moved.emit(event.relative.x, event.relative.y)

	# 视角模式切换
	if event.is_action_pressed("change_view"): view_change_requested.emit()

	# 移动动作
	if event.is_action_pressed("jump"): jump_pressed.emit()
	if event.is_action_pressed("sprint"): sprint_pressed.emit()
	if event.is_action_released("sprint"): sprint_released.emit()
	if event.is_action_pressed("crouch"): crouch_toggled.emit()

	# 战斗动作
	if event.is_action_pressed("attack"): attack_pressed.emit()
	if event.is_action_pressed("reload"): reload_pressed.emit()
	if event.is_action_pressed("change_weapon_next"): change_weapon_next.emit()
	if event.is_action_pressed("change_weapon_prev"): change_weapon_prev.emit()

func _on_view_state_changed(new_state: int) -> void:
	is_logic_input_active = (new_state != ViewStateManager.State.FREE_DRONE)
