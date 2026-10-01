extends PlayerState
class_name PlayerGroundState

func physics_update(_delta: float) -> void:
    if not player.is_on_floor():
        state_machine.transition_to("Airborne")

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed("crouch"):
        state_machine.transition_to("Crouch")
    if event.is_action_pressed("jump"):
        state_machine.transition_to("Airborne", {"do_jump": true})