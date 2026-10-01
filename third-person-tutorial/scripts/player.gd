extends CharacterBody3D

@onready var camera_mount: Node3D = $CameraMount
@onready var animation_player: AnimationPlayer = $Visuals/mixamo_base/AnimationPlayer
@onready var visuals: Node3D = $Visuals

const JUMP_VELOCITY = 4.5

var speed := 0.0
var walking_speed := 3.0
var running_speed := 5.0
var turn_speed := 10.0
var deceleration := 20.0

var sen_horizontal := 0.1
var sen_vertical := 0.1

var running: bool = false
var is_locked: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sen_horizontal))
		visuals.rotate_y(deg_to_rad(event.relative.x * sen_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sen_vertical))
		camera_mount.rotation.x = clampf(camera_mount.rotation.x, deg_to_rad(-85), deg_to_rad(85))

func _physics_process(delta: float) -> void:

	if !animation_player.is_playing():
		is_locked = false

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("kick"):
		if animation_player.current_animation != "kick":
			animation_player.play("kick")
			is_locked = true

	if Input.is_action_pressed("run"):
		speed = running_speed
		running = true
	else:
		speed = walking_speed
		running = false

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		if !is_locked:
			if running:
				if animation_player.current_animation != "running" and is_on_floor():
					animation_player.play("running")
				elif animation_player.current_animation != "idle" and !is_on_floor():
					animation_player.play("idle")
			else:
				if animation_player.current_animation != "walking" and is_on_floor():
					animation_player.play("walking")
				elif animation_player.current_animation != "idle" and !is_on_floor():
					animation_player.play("idle")

			var target := Transform3D(Basis.looking_at(direction, Vector3.UP), Vector3.ZERO)

		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

	else:
		if !is_locked:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")

		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		velocity.z = move_toward(velocity.z, 0, deceleration * delta)

	if !is_locked:
		move_and_slide()
