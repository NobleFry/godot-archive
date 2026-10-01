extends Node
class_name DroneState

var drone: Drone
var player: Player

func enter() -> void: pass

func exit() -> void: pass

func handle_input(_event: InputEvent) -> void: pass

func physics_update(_delta: float) -> void: pass
