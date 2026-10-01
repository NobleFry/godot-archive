extends PlayerGroundState

func physics_update(delta: float) -> void:
	super.physics_update(delta)

	var move_dir = get_move_direction()
	if move_dir == Vector3.ZERO:
		state_machine.transition_to("Idle")
		return

	var speed = player.walk_speed

	player.velocity.x = move_toward(player.velocity.x, move_dir.x * speed, player.acceleration * delta)
	player.velocity.z = move_toward(player.velocity.z, move_dir.z * speed, player.acceleration * delta)

	player.move_and_slide()

func handle_input(event: InputEvent) -> void:
	super.handle_input(event)
	
	if event.is_action_pressed("sprint"):
		state_machine.transition_to("Sprint")
