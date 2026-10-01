extends DroneState

@export var max_speed := 8.0
@export var acceleration := 12.0
@export var friction := 8.0
@export var mouse_sensitivity := 0.002

func enter() -> void:
	drone.visible = true
	drone.set_physics_process(true)
	drone.set_process_unhandled_input(true)

	if drone.battery:
		drone.battery.set_drain_multiplier(1.0)
		drone.battery.start_draining()

func exit() -> void:
	drone.velocity = Vector3.ZERO

func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		drone.rotate_y(-event.relative.x * mouse_sensitivity)
		drone.rotate_x(-event.relative.y * mouse_sensitivity)
		drone.drone_camera.rotation.x = clamp(drone.drone_camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func physics_update(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var move_up_down = Input.get_axis("down", "up")

	var cam_basis = drone.drone_camera.global_transform.basis
	var horizontal_dir = (cam_basis.x * input_dir.x + cam_basis.z * input_dir.y)
	horizontal_dir.y = 0
	horizontal_dir = horizontal_dir.normalized()

	if horizontal_dir or move_up_down != 0:
		drone.velocity.x = move_toward(drone.velocity.x, horizontal_dir.x * max_speed, acceleration * delta)
		drone.velocity.z = move_toward(drone.velocity.z, horizontal_dir.z * max_speed, acceleration * delta)
		drone.velocity.y = move_toward(drone.velocity.y, move_up_down * max_speed, acceleration * delta)
	else:
		drone.velocity.x = move_toward(drone.velocity.x, 0, friction * delta)
		drone.velocity.z = move_toward(drone.velocity.z, 0, friction * delta)
		drone.velocity.y = move_toward(drone.velocity.y, 0, friction * delta)

	drone.move_and_slide()
