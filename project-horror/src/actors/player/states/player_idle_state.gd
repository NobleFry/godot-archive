extends PlayerGroundState

func enter(_msg := {}) -> void:
	# 不再瞬间归零，让 physics_update 里的摩擦力自然减速
	pass

func physics_update(delta: float) -> void:
	super.physics_update(delta)
	
	# 使用摩擦力平滑减速
	player.velocity.x = move_toward(player.velocity.x, 0, player.friction * delta)
	player.velocity.z = move_toward(player.velocity.z, 0, player.friction * delta)
	player.move_and_slide()

	# 如果有移动输入，切换到移动状态
	if player.input_controller.current_input_dir != Vector2.ZERO:
		state_machine.transition_to("Move")
