extends WeaponBase
class_name EnemyMeleeWeapon

@onready var hitbox: HitboxComponent = $HitboxComponent

func attack() -> void:
	if not can_attack: return
	
	start_cooldown()

	if hitbox:
		hitbox.monitoring = true
		print("hitbox monitoring")
		await get_tree().create_timer(0.2).timeout
		hitbox.monitoring = false
