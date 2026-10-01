extends Area3D
class_name HitboxComponent

@export var damage: float = 10.0

func _ready() -> void:
	# 只有在攻击时开启检测
	monitoring = false
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	if area is HurtboxComponent:
		area.handle_hit(damage)
		print("handle hit")
