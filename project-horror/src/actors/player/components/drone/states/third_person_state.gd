extends DroneState

func enter() -> void:
	drone.visible = true
	drone.set_physics_process(true)
	drone.set_process_unhandled_input(true)

	if drone.battery:
		drone.battery.set_drain_multiplier(drone.follow_drain_multiplier)
		drone.battery.start_draining()

func physics_update(_delta: float) -> void:
	if not player:
		return
	var target = player.global_position + drone.follow_offset
	drone.global_position = target
