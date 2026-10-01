extends Node
class_name HealthComponent

signal health_changed(current_health: float, max_health: float)
signal died

@export var max_health: float = 100.0

var current_health: float
var is_dead: bool = false

func _ready() -> void:
	current_health = max_health
	health_changed.emit.call_deferred(current_health, max_health)

func take_damage(amount: float) -> void:
	if is_dead: return

	current_health = clamp(current_health - amount, 0, max_health)
	health_changed.emit(current_health, max_health)
	print("current health:", current_health)

	if current_health <= 0:
		died.emit()

func heal(amount: float) -> void:
	if is_dead: return

	current_health = clamp(current_health + amount, 0, max_health)
	health_changed.emit(current_health, max_health)
