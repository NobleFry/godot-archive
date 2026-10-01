# 挂载到 Guard 场景下作为子节点
extends Node3D
class_name HearingSensor

signal noise_heard(noise_position: Vector3, intensity: float, noise_type: String)

# 听力灵敏度
@export var hearing_sensitivity: float = 1.0

# 最大听力距离上限
@export var max_hearing_distance: float = 30.0

# 被墙壁阻挡时的衰减倍率
@export var wall_attenuation: float = 0.5

# 墙壁检测的碰撞层
@export var environment_mask: int = 1

func _ready():
	# 连接噪音系统的噪音事件
	NoiseSystem.noise_emitted.connect(_on_noise_emitted)

func _on_noise_emitted(noise_position: Vector3, intensity: float, noise_type: String) -> void:
	# 计算距离
	var distance = global_position.distance_to(noise_position)

	# 有效听力范围 = 声音强度 x 灵敏度
	var effective_range = intensity * hearing_sensitivity

	# 限制最大距离
	effective_range = minf(effective_range, max_hearing_distance)

	# 距离过远，听不到
	if distance > effective_range:
		return

	# 检查墙壁阻挡
	if _is_blocked_by_wall(noise_position):
		# 墙壁后面的声音需要衰减后重新判断
		effective_range *= wall_attenuation
		if distance > effective_range:
			return

	# 声音被听到，发出信号
	noise_heard.emit(noise_position, intensity, noise_type)

# 射线检测：声源和敌人之间是否有墙壁
func _is_blocked_by_wall(noise_position: Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position + Vector3(0, 1.0, 0),
		noise_position + Vector3(0, 0.5, 0),
		environment_mask
	)
	var result = space_state.intersect_ray(query)
	return not result.is_empty()
