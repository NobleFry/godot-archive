extends PlayerGroundState

func enter(_msg := {}) -> void:
	player.is_crouching = true

func exit() -> void:
	player.is_crouching = false

func physics_update(delta: float) -> void:
	super.physics_update(delta)
	
	var move_dir = get_move_direction()
	var speed = player.crouch_speed
	
	player.velocity.x = move_toward(player.velocity.x, move_dir.x * speed, player.acceleration * delta)
	player.velocity.z = move_toward(player.velocity.z, move_dir.z * speed, player.acceleration * delta)
	
	player.move_and_slide()

func handle_input(event: InputEvent) -> void:
	# 取消调用 super.handle_input 防止父类再次触发进入下蹲
	
	# 再次按下下蹲键或跳跃键时退出下蹲
	if event.is_action_pressed("crouch") or event.is_action_pressed("jump"):
		if player.can_stand_up():
			if player.input_controller.current_input_dir != Vector2.ZERO:
				state_machine.transition_to("Move")
			else:
				state_machine.transition_to("Idle")
	
	# 下蹲时按下冲刺键，尝试站起并直接进入冲刺
	if event.is_action_pressed("sprint"):
		if player.can_stand_up():
			state_machine.transition_to("Sprint")
