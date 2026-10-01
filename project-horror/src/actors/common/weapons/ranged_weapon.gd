# 中间件
# 职责：管理弹药，装弹状态，射程，射线检测或子弹生成

extends WeaponBase
class_name RangedWeapon

@export var max_ammo: int = 12
@export var reload_time: float = 1.5

@onready var ray_cast: RayCast3D = $RayCast3D

var current_ammo: int
var is_reloading: bool = false

var reload_timer: Timer

func _ready() -> void:
	super ()
	current_ammo = max_ammo

	# 设置装弹计时器
	reload_timer = Timer.new()
	reload_timer.one_shot = true
	reload_timer.wait_time = reload_time
	reload_timer.timeout.connect(_on_reload_finished)
	add_child(reload_timer)

# 统一的攻击接口
func attack() -> void:
	if not can_attack or is_reloading:
		print("can't fire")
		print(can_attack, is_reloading)
		return

	if current_ammo > 0:
		print("have enough ammo")
		_fire()
	else:
		print("no ammo")

func _fire() -> void:
	start_cooldown()
	current_ammo -= 1

	print("fire,ammo left：", current_ammo)

	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()

		if collider is HurtboxComponent:
			collider.handle_hit(damage)
		elif collider.has_method("handle_hit"): # 容错处理
			collider.handle_hit(damage)

func reload() -> void:
	if is_reloading or current_ammo == max_ammo:
		return

	is_reloading = true
	reload_timer.start()

func _on_reload_finished() -> void:
	current_ammo = max_ammo
	is_reloading = false
	print("reload finished")
