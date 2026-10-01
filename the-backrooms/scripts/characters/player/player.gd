extends CharacterBody3D

enum Stance { STAND, CROUCH, PRONE }
enum Movement { IDLE, WALK, SPRINT, FALL }

@export_group("Movement Parameters")
@export var walk_speed: float = 1.5
@export var sprint_speed: float = 2.5
@export var crouch_speed: float = 1.0
@export var prone_speed: float = 0.6
@export var jump_velocity: float = 3.0
@export var ground_accel: float = 50.0
@export var ground_decel: float = 40.0
@export var air_accel: float = 20.0
@export var air_decel: float = 0.5

@export_group("Height Settings")
@export var stand_height: float = 1.8
@export var crouch_height: float = 1.2
@export var prone_height: float = 0.8
@export var eye_height_ratio: float = 0.88
@export var crouch_lerp_speed: float = 3.0

@export_group("Camera & FOV")
@export var mouse_sensitivity: float = 3.5
@export var max_pitch_deg:float = 85.0
@export var base_fov: float = 75.0
@export var sprint_fov: float = 90
@export var fov_lerp_speed: float = 8.0
@export var radians_per_pixel: float = 0.000665

var current_stance: Stance = Stance.STAND
var current_movement: Movement = Movement.IDLE
var current_speed: float = walk_speed

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var shape_cast: ShapeCast3D = $ShapeCast3D
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if collider.shape:
		collider.shape = collider.shape.duplicate()

	camera.fov = base_fov

func _unhandled_input(event: InputEvent) -> void:
	handle_mouse(event)

func _input(event) -> void:
	handle_jump(event)

func _physics_process(delta: float) -> void:
	update_state_machine()

	handle_gravity(delta)
	handle_movement(delta)

	handle_height_transitions(delta)

	move_and_slide()

func handle_mouse(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_mouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var yaw = -event.screen_relative.x * mouse_sensitivity * radians_per_pixel
		var pitch = -event.screen_relative.y * mouse_sensitivity * radians_per_pixel

		rotate_y(yaw)
		camera_pivot.rotate_x(pitch)
		camera_pivot.rotation.x = clampf(
			camera_pivot.rotation.x, deg_to_rad(-max_pitch_deg), deg_to_rad(max_pitch_deg)
		)

func update_state_machine() -> void:
	# 解析玩家意图
	var wants_to_prone = Input.is_action_pressed("prone")
	var wants_to_crouch = Input.is_action_pressed("crouch")
	var wants_to_sprint = Input.is_action_pressed("sprint")

	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "back")	
	var is_moving = input_dir.length() > 0.1

	var desired_stance = Stance.STAND

	if is_on_floor():
		if wants_to_prone:
			desired_stance = Stance.PRONE
		elif wants_to_crouch:
			desired_stance = Stance.CROUCH
	
	var target_stance = desired_stance

	if target_stance == Stance.STAND and !has_headroom(stand_height):
		target_stance = Stance.CROUCH

	if target_stance == Stance.CROUCH and !has_headroom(crouch_height):
		target_stance = Stance.PRONE

	current_stance = target_stance

	if !is_on_floor():
		current_movement = Movement.FALL
	elif !is_moving:
		current_movement = Movement.IDLE
	else:
		if current_stance == Stance.STAND and wants_to_sprint:
			current_movement = Movement.SPRINT
		else:
			current_movement = Movement.WALK

	match current_movement:
		Movement.SPRINT:
			current_speed = sprint_speed
		Movement.WALK:
			match current_stance:
				Stance.STAND: current_speed = walk_speed
				Stance.CROUCH: current_speed = crouch_speed
				Stance.PRONE: current_speed = prone_speed
		Movement.IDLE, Movement.FALL:
			pass

func has_headroom(target_height: float) -> bool:
	if !shape_cast: return true

	var radius: float = 0.3
	var current_height: float = (collider.shape as CapsuleShape3D).height

	var height_diff: float = target_height - current_height

	if height_diff <= 0.0:
		return true

	shape_cast.position.y = current_height - radius

	shape_cast.target_position = Vector3(0, height_diff, 0)
	shape_cast.force_shapecast_update()

	return !shape_cast.is_colliding()

func handle_movement(delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "back")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var target_velocity: Vector3 = current_speed * direction

	var accel = ground_accel if is_on_floor() else air_accel
	var decel = ground_decel if is_on_floor() else air_decel

	if direction:
		velocity.x = move_toward(velocity.x, target_velocity.x, accel * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, decel * delta)
		velocity.z = move_toward(velocity.z, 0.0, decel * delta)

func handle_gravity(delta: float) -> void:
	if !is_on_floor():
		velocity.y -= gravity * delta
	
	if is_on_ceiling() and velocity.y > 0.0:
		velocity.y = 0.0

func handle_jump(event) -> void:
	if is_on_floor() and event.is_action_pressed("jump"):
		if current_stance == Stance.STAND:
			velocity.y = jump_velocity

func handle_height_transitions(delta: float) -> void:
	var shape = collider.shape as CapsuleShape3D
	var target_height: float

	match current_stance:
		Stance.PRONE: target_height = prone_height
		Stance.CROUCH: target_height = crouch_height
		Stance.STAND: target_height = stand_height
	
	shape.height = target_height
	collider.position.y = shape.height / 2.0

	var target_eye_height = target_height * eye_height_ratio
	camera_pivot.position.y = lerpf(camera_pivot.position.y, target_eye_height, crouch_lerp_speed * delta)
