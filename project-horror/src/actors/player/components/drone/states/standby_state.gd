extends DroneState

func enter() -> void:
	drone.visible = true
	drone.set_physics_process(false)
	drone.set_process_unhandled_input(false)

	drone.standby_position = drone.global_position

	if drone.battery:
		drone.battery.set_drain_multiplier(drone.low_drain_multiplier)
		drone.battery.start_draining()

func exit() -> void:
	if drone.battery:
		drone.battery.set_drain_multiplier(1.0)
