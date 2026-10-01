extends Node3D
class_name VisionSensor

# 当玩家被发现或丢失时触发信号
signal player_detected(player: Player)
signal player_lost(player: Player)

@export_group("Vision Settings")
@export var max_view_distance: float = 15.0 # 默认视距
@export var view_angle_degress: float = 90.0 # 视野角度
@export var environment_mask: int = 1 # 墙壁/遮挡物所在地的物理层碰撞掩码(Layer 1)

@export_group("Dynamic Vision")
@export var alert_view_distance: float = 20.0 # 警戒视距
@export var alert_view_angle: float = 120.0 # 警戒视锥
@export var chase_view_distance: float = 25.0 # 追逐视距
@export var chase_view_angle: float = 160.0 # 追逐视锥
@export var vision_transition_speed: float = 3.0 # 视野过渡速度

@onready var detection_area: Area3D = $DetectionArea
@onready var collision_shape: CollisionShape3D = $DetectionArea/CollisionShape3D
@onready var eye_position: Marker3D = $EyePosition

var current_target: Node3D = null
var _is_player_currently_seen: bool = false # 用于记忆上一帧的状态，防止信号连发

var _default_view_distance: float
var _default_view_angle: float

var _target_view_distance: float
var _target_view_angle: float

func _ready() -> void:
	# 显式复制资源，防止多个 AI 实例共享同一个半径设置
	if collision_shape.shape:
		collision_shape.shape = collision_shape.shape.duplicate()
	
	# 动态应用视距到球形碰撞体上
	if collision_shape.shape is SphereShape3D:
		collision_shape.shape.radius = max_view_distance

	# 绑定 Area3D 进出事件
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

	# 保存默认视距和视锥
	_default_view_distance = max_view_distance
	_default_view_angle = view_angle_degress

	# 保存目标视距和视锥
	_target_view_distance = alert_view_distance
	_target_view_angle = alert_view_angle

func _physics_process(_delta: float) -> void:
	# 平滑过渡视野参数
	max_view_distance = lerpf(max_view_distance, _target_view_distance, vision_transition_speed * _delta)
	view_angle_degress = lerpf(view_angle_degress, _target_view_angle, vision_transition_speed * _delta)

	# 同步碰撞体的大小
	if collision_shape.shape is SphereShape3D:
		collision_shape.shape.radius = max_view_distance

	# 如果玩家在最大侦测光圈内，则每帧进行精确的视线和射线检测
	if current_target:
		var can_see = _is_target_in_vision_cone(current_target) and _has_line_of_sight(current_target)
		
		# 只有在状态切换时才发出信号
		if can_see and not _is_player_currently_seen:
			_is_player_currently_seen = true
			player_detected.emit(current_target)
		elif not can_see and _is_player_currently_seen:
			_is_player_currently_seen = false
			player_lost.emit(current_target)

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		current_target = body

func _on_body_exited(body: Node3D) -> void:
	if body == current_target:
		current_target = null
		if _is_player_currently_seen:
			_is_player_currently_seen = false
			player_lost.emit(body as Player)

# 扇形点乘计算，计算玩家是否在视野范围内
func _is_target_in_vision_cone(target: Node3D) -> bool:
	# 获取敌人正前方的方向向量(Global Forward)
	var forward_dir: Vector3 = - global_transform.basis.z.normalized()

	# 获取从敌人眼睛到玩家的相对方向向量
	var direction_to_target: Vector3 = (target.global_position - global_position).normalized()

	# 使用点乘计算夹角
	var dot_product: float = forward_dir.dot(direction_to_target)

	# 将我们设置的角度转换为弧度的余弦值(因为点乘的结果是余弦值)
	# view_angle_degress 是总角度，我们需要除以 2 得到半角，然后算 cos
	var limit_cosine: float = cos(deg_to_rad(view_angle_degress / 2.0))

	# 如果点乘结果大于给定的阀值，就说明目标在视锥体内(余弦的值越大，角度越小，所以点乘结果的角度要小于阀值的话，需要点乘余弦值大于阀值余弦值)
	var is_in_cone: bool = dot_product >= limit_cosine

	# if is_in_cone:
	# 	print("玩家进入视锥范围")
	# else:
	# 	print("玩家不在视锥范围")
	# 	if dot_product < 0:
	# 		print("玩家在敌人背后")
	# 	else:
	# 		print("玩家在敌人前方,但不在视锥范围内")

	return is_in_cone

# 射线检测有无墙体遮挡
func _has_line_of_sight(target: Node3D) -> bool:
	var space_state = get_world_3d().direct_space_state

	# 射线起点:敌人的眼睛
	var start_pos = eye_position.global_position

	# 射线终点:玩家眼睛靠下位置（或者是身高的中间）
	# 使用目标自适应身高定位，代替硬编码
	var y_offset = 1.0
	if target is Player and "player_height" in target:
		y_offset = target.player_height / 2.0
	var end_pos = target.global_position + Vector3(0, y_offset, 0)

	# 发射射线，专门检测掩蔽物层 (environment_mask)
	var query = PhysicsRayQueryParameters3D.create(start_pos, end_pos, environment_mask)
	# 排除自身和玩家本身
	query.exclude = [ self.get_parent(), target]

	var result = space_state.intersect_ray(query)

	# 如果字典为空，说明射线没有打到任何墙壁，视线通畅
	return result.is_empty()

func set_vision_mode(mode: String) -> void:
	match mode:
		"idle":
			_target_view_distance = _default_view_distance
			_target_view_angle = _default_view_angle
		"alert":
			_target_view_distance = alert_view_distance
			_target_view_angle = alert_view_angle
		"chase":
			_target_view_distance = chase_view_distance
			_target_view_angle = chase_view_angle
