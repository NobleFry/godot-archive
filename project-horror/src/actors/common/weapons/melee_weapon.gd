# 中间件
# 职责：管理近战hitbox的开关，攻击判定的持续时间

extends WeaponBase
class_name MeleeWeapon

@onready var hitbox: HitboxComponent = $HitboxComponent

func attack():
	if not can_attack: return

	# 进入冷却
	start_cooldown()

	if hitbox:
		hitbox.monitoring = true
		await get_tree().create_timer(0.2).timeout
		hitbox.monitoring = false
