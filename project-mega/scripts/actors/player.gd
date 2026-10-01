extends CharacterBody3D

@export_group("Movement Parameters")
@export var walk_speed := 2.5
@export var sprint_speed := 4.0
@export var crouch_speed := 2.0
@export var jump_velocity := 3.0
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

@onready var camera_pivot: Node3D = $CameraPivot
@onready var collider: CollisionShape3D = $CollisionShape3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_apply_capsule_height(stand_height)
	camera_pivot.position.y = camera_stand_y


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_mouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var yaw = -event.relative.x * mouse_sensitivity * 0.01
		var pitch = -event.relative.y * mouse_sensitivity * 0.01
		rotate_y(yaw)
		camera_pivot.rotate_x(pitch)
		camera_pivot.rotation.x = clampf(
			camera_pivot.rotation.x, deg_to_rad(-max_pitch_deg), deg_to_rad(max_pitch_deg)
		)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

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


func _apply_capsule_height(h: float) -> void:
	if collider.shape is CapsuleShape3D:
		var capsule := collider.shape as CapsuleShape3D
		capsule.height = h
