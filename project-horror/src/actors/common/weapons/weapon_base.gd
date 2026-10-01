# 武器基类
# 职责：管理武器的生命周期（激活/禁用），通用CD计时器，基础属性
# 核心接口：attack(), reload(), activate(), deactivate()

extends Node3D
class_name WeaponBase

@export var weapon_name: String = "BaseWeapon" # 武器名字
@export var damage: float = 10.0 # 攻击伤害
@export var attack_range: float = 2.0 # 攻击范围
@export var attack_rate: float = 1.5 # 攻击频率
@export var noise_intensity_on_attack: float = 15.0 # 在武器基类里定义噪音强度
@export var noise_intensity_on_reload: float = 5.0

var can_attack: bool = true
var attack_timer: Timer

func _ready() -> void:
	attack_timer = Timer.new()
	attack_timer.one_shot = true
	attack_timer.wait_time = 1.0 / attack_rate
	attack_timer.timeout.connect(_on_attack_cooldown_finished)
	add_child(attack_timer)

# 开始冷却（子类在攻击后调用）
func start_cooldown() -> void:
	can_attack = false
	attack_timer.start()

func _on_attack_cooldown_finished() -> void:
	can_attack = true


func attack() -> void:
	pass

func reload() -> void:
	pass

# 用于切换武器时的状态控制
func activate() -> void:
	show()
	set_process(true)
	set_physics_process(true)

func deactivate() -> void:
	hide()
	set_process(false)
	set_physics_process(false)
