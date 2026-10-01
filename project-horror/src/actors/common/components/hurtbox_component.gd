extends Area3D
class_name HurtboxComponent

@onready var health_component: HealthComponent = $"../HealthComponent"

func handle_hit(damage: float) -> void:
	if health_component:
		health_component.take_damage(damage)
