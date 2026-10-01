# 挂载到 Player 场景下的一个 Node 子节点上
extends Node

# 各种动作的噪音强度
@export_group("Noise Intensities")
@export var sprint_noise: float = 15.0
@export var walk_noise: float = 6.0
@export var crouch_noise: float = 0.0

# 噪声发射间隔（防止每帧都发）
@export var noise_interval: float = 0.3

@onready var player: Player = get_parent()

var noise_timer: float = 0.0

func _physics_process(delta: float) -> void:
	noise_timer += delta
	
	# 只有在移动时才计算噪音
	var horizontal_speed = Vector2(player.velocity.x, player.velocity.z).length()
	var is_moving = horizontal_speed > 0.1

	if is_moving and noise_timer >= noise_interval:
		noise_timer = 0.0
		_emit_movement_noise()

# 根据玩家当前运动状态发出对应的脚步噪音
func _emit_movement_noise() -> void:
	var intensity: float
	var noise_type: String

	if player.is_sprinting:
		intensity = sprint_noise
		noise_type = "sprint"
	elif player.is_crouching:
		intensity = crouch_noise
		noise_type = "crouch_walk"
	else:
		intensity = walk_noise
		noise_type = "walk"
	
	# 发射噪音
	NoiseSystem.emit_noise(player.global_position, intensity, noise_type)

# 武器相关噪音 - 外部调用
# func emit_weapon_noise(noise_type: String) -> void:
# 	var intensity: float
# 	match noise_type:
# 		"fire":
# 			intensity = weapon_fire_noise
# 		"melee":
# 			intensity = weapon_melee_noise
# 		"reload":
# 			intensity = reload_noise
# 		_:
# 			intensity = weapon_melee_noise
	
# 	NoiseSystem.emit_noise(player.global_position, intensity, noise_type)

func emit_custom_noise(intensity: float, noise_type: String) -> void:
	NoiseSystem.emit_noise(player.global_position, intensity, noise_type)
