extends DroneState

func enter() -> void:
	drone.visible = false
	drone.set_physics_process(false)
	drone.set_process_unhandled_input(false)
	drone.velocity = Vector3.ZERO

	if drone.battery:
		drone.battery.stop_draining()
