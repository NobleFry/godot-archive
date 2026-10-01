extends Node
class_name ViewStateManager

signal state_changed(new_state)

enum State {
	FIRST_PERSON,
	THIRD_PERSON_DRONE,
	FREE_DRONE
}

var current_state: State = State.FIRST_PERSON:
	set(value):
		if current_state != value:
			current_state = value
			state_changed.emit(current_state)

func switch_to_first_person():
	current_state = State.FIRST_PERSON

func switch_to_third_person():
	current_state = State.THIRD_PERSON_DRONE

func switch_to_free_drone():
	current_state = State.FREE_DRONE
