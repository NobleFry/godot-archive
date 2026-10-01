extends Node3D

# 灵敏度和相机旋转限制
@export var mouse_sensitivity = 0.002
@export var tilt_lower_limit := deg_to_rad(-90.0)
@export var tilt_upper_limit := deg_to_rad(90.0)

# 下蹲时相机的目标高度和缓冲速度
@export var head_y_stand_offset: float = 0.0 # 相对于基础高度的站立相机偏移
@export var head_y_crouch_offset: float = -0.5 # 相对于基础高度的下蹲相机微调
@export var head_transition_speed: float = 10.0

# 获取节点
@onready var player: Player = owner
@onready var visuals: Node3D = %Visuals
@onready var player_mesh: MeshInstance3D = %MeshInstance3D
@onready var fp_camera: Camera3D = $FirstPersonCamera
@onready var tp_camera: Camera3D = $SpringArm3D/ThirdPersonCamera
@onready var view_state_manager: ViewStateManager = %ViewStateManager
@onready var input_controller: PlayerInputController = %PlayerInputController

var is_first_person: bool = true

func _ready():
	_apply_view_state(view_state_manager.current_state)
	view_state_manager.state_changed.connect(_apply_view_state)
	
	input_controller.camera_moved.connect(_on_camera_moved)
	input_controller.view_change_requested.connect(_on_view_change_requested)
	input_controller.drone_deploy_requested.connect(_on_drone_deploy_requested)

func _on_camera_moved(rot_x: float, rot_y: float):
	var tilt_x = - rot_y * mouse_sensitivity
	var tilt_y = - rot_x * mouse_sensitivity

	if is_first_person:
		player.rotate_y(tilt_y)
		visuals.rotation.y = 0
	else:
		rotation.y += tilt_y
	
	rotation.x += tilt_x
	rotation.x = clampf(rotation.x, tilt_lower_limit, tilt_upper_limit)

func _on_view_change_requested():
	if view_state_manager.current_state == ViewStateManager.State.FIRST_PERSON:
		view_state_manager.switch_to_third_person()
	elif view_state_manager.current_state == ViewStateManager.State.THIRD_PERSON_DRONE:
		view_state_manager.switch_to_first_person()

func _on_drone_deploy_requested():
	if view_state_manager.current_state != ViewStateManager.State.FREE_DRONE:
		view_state_manager.switch_to_free_drone()
	else:
		view_state_manager.switch_to_first_person()


func _process(delta):
	if view_state_manager.current_state == ViewStateManager.State.FREE_DRONE:
		return

	# 计算自适应的相机基础高度：原始1.8m时头部基础高度增量为0
	var height_diff = (player.player_height - 1.8) / 2.0
	var current_head_y_stand = height_diff + head_y_stand_offset
	# 下蹲时相比站立下降的绝对距离（按原身高的比例 0.5/1.8）
	var drop_distance = player.player_height * (0.5 / 1.8)
	var current_head_y_crouch = current_head_y_stand - drop_distance + (head_y_crouch_offset - (-0.5))

	var target_head_y = current_head_y_crouch if player.is_crouching else current_head_y_stand
	position.y = lerp(position.y, target_head_y, head_transition_speed * delta)

func _apply_view_state(new_state: ViewStateManager.State) -> void:
	is_first_person = (new_state == ViewStateManager.State.FIRST_PERSON)
	match new_state:
		ViewStateManager.State.FIRST_PERSON:
			fp_camera.current = true
			tp_camera.current = false
			player_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY

			# 恢复第一人称视角的模型对齐
			player.global_rotation.y = global_rotation.y
			rotation.y = 0
			visuals.rotation.y = 0

		ViewStateManager.State.THIRD_PERSON_DRONE:
			fp_camera.current = false
			tp_camera.current = true
			player_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

		ViewStateManager.State.FREE_DRONE:
			fp_camera.current = false
			tp_camera.current = false
			player_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
