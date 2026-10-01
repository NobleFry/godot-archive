extends CharacterBody3D

@export_group("Jump")
@export var jump_velocity := 3.5
@export var jump_camera_offset := 0.3
@export var jump_offset_speed_up := 8.0
@export var jump_offset_speed_down := 10.0
@export var land_dip_amount := -0.2
@export var land_dip_speed := 5.0
@export var land_dip_sharpness := 40
@export var land_fall_ref_speed := 5.0
@export var land_dip_scale_min := 0.3
@export var land_dip_scale_max := 1.0

@export_group("Movement Parameters")
@export var walk_speed := 2.5
@export var sprint_speed := 4.0
@export var crouch_speed := 2.0
@export var ground_accel := 50.0
@export var ground_decel := 40.0
@export var air_accel := 20.0
@export var air_decel := 0.5

@export_group("Player Settings")
@export var stand_height := 1.8
@export var crouch_height := 1.2
@export var camera_stand_y := 0.7
@export var camera_crouch_y := 0.3
@export var mouse_sensitivity := 0.12
@export var max_pitch_deg := 85.0

@export_group("Camera Roll")
@export var roll_amount := 0.15
@export var roll_speed := 4

@export_group("Dialogue")
@export var look_at_speed := 8.0
@export var look_at_duration := 0.5

@onready var camera_pivot: Node3D = $CameraPivot
@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var head_bob: Node3D = $CameraPivot/HeadBob

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _roll_velocity: float = 0.0
var _was_on_floor: bool = true
var _jump_camera_offset_y: float = 0.0

# 着陆状态机：none → dip（下沉）→ rebound（回弹）→ none
enum LandPhase { NONE, DIP, REBOUND }
var _land_phase: LandPhase = LandPhase.NONE
var _land_dip_target: float = 0.0
var can_move: bool = true
var _was_mouse_captured: bool = true
var _dialogue_target: Node3D = null
var _look_timer: float = 0.0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_apply_capsule_height(stand_height)
	camera_pivot.position.y = camera_stand_y
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func _on_dialogue_started(npc: Node3D) -> void:
	can_move = false
	_was_mouse_captured = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if npc:
		_dialogue_target = npc
		_look_timer = -1.0  # -1 表示持续锁定


func _on_dialogue_ended() -> void:
	can_move = true
	if _was_mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_dialogue_target = null
	_look_timer = 0.0


func _unhandled_input(event: InputEvent) -> void:
	if can_move and event.is_action_pressed("toggle_mouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return

# =====================================================================================

	if not can_move:
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var yaw = -event.relative.x * mouse_sensitivity * 0.01
		var pitch = -event.relative.y * mouse_sensitivity * 0.01
		rotate_y(yaw)
		camera_pivot.rotate_x(pitch)
		camera_pivot.rotation.x = clampf(
			camera_pivot.rotation.x, deg_to_rad(-max_pitch_deg), deg_to_rad(max_pitch_deg)
		)
		# 累加 roll 速度：鼠标右移 → 负 roll（右倾），鼠标左移 → 正 roll（左倾）
		_roll_velocity -= event.relative.x * roll_amount * 0.001

# =====================================================================================

func _physics_process(delta: float) -> void:
	if not can_move:
		velocity = Vector3.ZERO
		move_and_slide()
		# 对话期间自动转向 NPC
		if _dialogue_target and _look_timer != 0.0:
			_look_timer -= delta
			var target_pos := _dialogue_target.global_position
			target_pos.y = global_position.y
			var target_dir := (target_pos - global_position).normalized()
			var target_basis := Basis.looking_at(target_dir)
			var current_basis := global_basis
			var new_basis := current_basis.slerp(target_basis, look_at_speed * delta)
			global_basis = new_basis.orthonormalized()
		return

	# 在 move_and_slide 之前采样下落速度
	var pre_slide_vel_y := velocity.y

	if not is_on_floor():
		velocity.y -= gravity * delta

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity
		_land_phase = LandPhase.NONE

	var input_vec = Vector2.ZERO
	input_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	var speed = walk_speed
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed

	var direction = (transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()
	var target_vel = direction * speed

	if is_on_floor():
		if input_vec != Vector2.ZERO:
			velocity.x = move_toward(velocity.x, target_vel.x, ground_accel * delta)
			velocity.z = move_toward(velocity.z, target_vel.z, ground_accel * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, ground_decel * delta)
			velocity.z = move_toward(velocity.z, 0.0, ground_decel * delta)
	else:
		if input_vec != Vector2.ZERO:
			velocity.x = move_toward(velocity.x, target_vel.x, air_accel * delta)
			velocity.z = move_toward(velocity.z, target_vel.z, air_accel * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, air_accel * delta)
			velocity.z = move_toward(velocity.z, 0.0, air_accel * delta)

	move_and_slide()

# =====================================================================================

	# 跳跃镜头偏移
	if _land_phase == LandPhase.NONE and not _was_on_floor and is_on_floor():
		# 着陆：用 move_and_slide 之前的下落速度计算缩放
		var fall_speed := absf(pre_slide_vel_y)
		var ratio := clampf(fall_speed / land_fall_ref_speed, 0.0, 1.0)
		var dip_scale := lerpf(land_dip_scale_max, land_dip_scale_min, ratio)
		_land_dip_target = land_dip_amount * dip_scale
		_land_phase = LandPhase.DIP

	match _land_phase:
		LandPhase.DIP:
			_jump_camera_offset_y = lerpf(
				_jump_camera_offset_y, _land_dip_target,
				1.0 - exp(-land_dip_sharpness * delta)
			)
			if absf(_jump_camera_offset_y - _land_dip_target) < 0.01:
				_land_phase = LandPhase.REBOUND
		LandPhase.REBOUND:
			_jump_camera_offset_y = lerpf(
				_jump_camera_offset_y, 0.0,
				1.0 - exp(-land_dip_speed * delta)
			)
			if absf(_jump_camera_offset_y) < 0.005:
				_jump_camera_offset_y = 0.0
				_land_phase = LandPhase.NONE
		LandPhase.NONE:
			if not is_on_floor() and velocity.y > 0:
				_jump_camera_offset_y = lerpf(
					_jump_camera_offset_y, jump_camera_offset,
					1.0 - exp(-jump_offset_speed_up * delta)
				)
			elif not is_on_floor() and velocity.y <= 0:
				_jump_camera_offset_y = lerpf(
					_jump_camera_offset_y, 0.0,
					1.0 - exp(-jump_offset_speed_down * delta * 0.5)
				)

	camera_pivot.position.y = camera_stand_y + _jump_camera_offset_y

	_was_on_floor = is_on_floor()

	var h_speed := Vector2(velocity.x, velocity.z).length()
	head_bob.update(h_speed, is_on_floor(), Input.is_action_pressed("sprint"))

	# Camera roll：指数衰减回归水平
	_roll_velocity *= exp(-roll_speed * delta)
	camera_pivot.rotation.z = _roll_velocity

# =====================================================================================

func _apply_capsule_height(h: float) -> void:
	if collider.shape is CapsuleShape3D:
		var capsule := collider.shape as CapsuleShape3D
		capsule.height = h
