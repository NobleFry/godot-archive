extends PlayerState

func enter(msg := {}) -> void:
	# 如果是从地面主动跳起
	if msg.has("do_jump"):
		player.velocity.y = player.jump_velocity

func physics_update(delta: float) -> void:
	# 应用重力
	player.velocity.y -= player.gravity * delta
	
	# 空中移动控制（保持冲刺速度，如果起跳时正在冲刺）
	var input_dir = get_move_direction()
	var target_speed = player.sprint_speed if player.is_sprinting else player.walk_speed
	
	player.velocity.x = move_toward(player.velocity.x, input_dir.x * target_speed, player.acceleration * delta)
	player.velocity.z = move_toward(player.velocity.z, input_dir.z * target_speed, player.acceleration * delta)
	
	player.move_and_slide()

	# 落地检测
	if player.is_on_floor():
		if player.input_controller.current_input_dir != Vector2.ZERO:
			if player.is_sprinting:
				state_machine.transition_to("Sprint")
			else:
				state_machine.transition_to("Move")
		else:
			state_machine.transition_to("Idle")
