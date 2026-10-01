extends CharacterBody3D
class_name Guard

# ======= 导出参数 =======

@export var walk_speed: float = 2.0
@export var turn_speed: float = 5.0

@export_group("Distance Control")
@export var stopping_distance: float = 1.5
@export var resume_distance: float = 2.0

@export_group("Investigation")
@export var investigate_timeout: float = 5.0
@export var investigate_turn_speed: float = 2.0
@export var investigate_arrival_dist: float = 1.0

# ======= 节点引用 =======

@onready var vision_sensor: VisionSensor = $VisionSensor
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar: Node3D = $HealthBar3d
@onready var weapon_manager: WeaponManager = $WeaponManager
@onready var hearing_sensor: HearingSensor = $HearingSensor

# ======= 状态机 =======

enum GuardState {IDLE, ALERT, CHASING, ATTACKING, INVESTIGATING}
var current_state: GuardState = GuardState.IDLE

# ======= 目标与记忆 =======

var target_player: Player = null
var last_known_position: Vector3 = Vector3.ZERO
var has_last_known_position: bool = false

# ======= 搜索计时器 =======

var investigate_timer: float = 0.0
var investigate_look_timer: float = 0.0
var investigate_look_direction: float = 0.0

# ======= 生命周期 =======

func _ready() -> void:
	# 绑定视觉检测信号
	vision_sensor.player_detected.connect(_on_player_detected)
	vision_sensor.player_lost.connect(_on_player_lost)

	# 绑定听觉检测信号
	hearing_sensor.noise_heard.connect(_on_noise_heard)

	# 绑定血量组件信号
	health_component.health_changed.connect(health_bar.update_health)
	health_component.died.connect(_on_guard_died)

	call_deferred("_actor_setup")
	call_deferred("_sync_weapon_range")

func _actor_setup() -> void:
	await get_tree().physics_frame

func _sync_weapon_range() -> void:
	if weapon_manager and weapon_manager.active_weapon:
		var weapon = weapon_manager.active_weapon
		stopping_distance = weapon.attack_range
		resume_distance = stopping_distance + 0.5

# ======= 主循环 =======

func _physics_process(delta: float) -> void:
	# 处理重力
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 状态机分发
	match current_state:
		GuardState.IDLE:
			_state_idle(delta)
		GuardState.ALERT:
			_state_alert(delta)
		GuardState.CHASING:
			_state_chasing(delta)
		GuardState.ATTACKING:
			_state_attacking(delta)
		GuardState.INVESTIGATING:
			_state_investigating(delta)
		
	move_and_slide()

# ======= 状态实现 =======

func _state_idle(delta: float) -> void:
	_stop_movement(delta)
	vision_sensor.set_vision_mode("idle")

func _state_alert(delta: float) -> void:
	_stop_movement(delta)
	vision_sensor.set_vision_mode("alert")

	# 如果有记忆位置，警戒过渡到调查
	if has_last_known_position:
		_change_state(GuardState.INVESTIGATING)

func _state_chasing(delta: float) -> void:
	if not target_player:
		return
	
	vision_sensor.set_vision_mode("chase")
	
	# 不断更新最后已知位置
	last_known_position = target_player.global_position
	has_last_known_position = true

	var dist_to_target = global_position.distance_to(target_player.global_position)

	# 进入攻击范围
	if dist_to_target <= stopping_distance:
		_change_state(GuardState.ATTACKING)
		return
	
	# 导航追逐
	_navigate_to(target_player.global_position, delta)

func _state_attacking(delta: float) -> void:
	if not target_player:
		return

	var dist_to_target = global_position.distance_to(target_player.global_position)

	# 玩家逃出攻击范围
	if dist_to_target >= resume_distance:
		_change_state(GuardState.CHASING)
		return

	# 停下来面朝玩家并攻击
	_stop_movement(delta)
	var look_dir = (target_player.global_position - global_position).normalized()
	look_dir.y = 0
	_look_at_direction(look_dir, delta)
	weapon_manager.trigger_attack()

	# 持续更新记忆
	last_known_position = target_player.global_position
	has_last_known_position = true

func _state_investigating(delta: float) -> void:
	vision_sensor.set_vision_mode("alert")
	
	if not has_last_known_position:
		_change_state(GuardState.IDLE)
		return

	var dist_to_target = global_position.distance_to(last_known_position)

	if dist_to_target > investigate_arrival_dist:
		# 还没到达，继续前往
		_navigate_to(last_known_position, delta)
	else:
		# 已达到，开始原地搜索
		_stop_movement(delta)
		_search_around(delta)

func _search_around(delta: float) -> void:
	investigate_timer += delta
	
	# 超时，放弃搜索
	if investigate_timer >= investigate_timeout:
		investigate_timer = 0.0
		has_last_known_position = false
		_change_state(GuardState.IDLE)
		return

	# 来回转头扫视
	investigate_look_timer += delta * (1.0 / investigate_turn_speed)
	var sweep_angle = sin(investigate_look_timer * 2.0 * PI) * PI * 0.4
	var base_forward = - global_transform.basis.z.normalized()
	var look_dir = base_forward.rotated(Vector3.UP, sweep_angle)
	_look_at_direction(look_dir, delta)

# ======= 辅助函数 =======

func _navigate_to(target_pos: Vector3, delta: float) -> void:
	var move_dir: Vector3 = Vector3.ZERO
	
	if nav_agent and nav_agent.is_inside_tree():
		if Engine.get_physics_frames() % 6 == 0:
			nav_agent.target_position = target_pos
		
		if not nav_agent.is_navigation_finished():
			var next_pos: Vector3 = nav_agent.get_next_path_position()
			move_dir = (next_pos - global_position).normalized()
		else:
			_stop_movement(delta)
			return
	else:
		move_dir = global_position.direction_to(target_pos).normalized()
		
	move_dir.y = 0
	_look_at_direction(move_dir, delta)
	velocity.x = move_dir.x * walk_speed
	velocity.z = move_dir.z * walk_speed

func _stop_movement(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 10.0 * delta)
	velocity.z = move_toward(velocity.z, 0, 10.0 * delta)

func _change_state(new_state: GuardState) -> void:
	# 退出旧状态清理
	match current_state:
		GuardState.INVESTIGATING:
			investigate_timer = 0.0
			investigate_look_timer = 0.0
	current_state = new_state
	print("[Guard]状态切换 ->", GuardState.keys()[new_state])

# 平滑注视方向
func _look_at_direction(direction: Vector3, delta: float) -> void:
	if direction.length_squared() > 0.01:
		var target_rotation_y = atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation_y, turn_speed * delta)

# ======= 信号回调 =======

func _on_player_detected(player: Player) -> void:
	target_player = player
	if current_state in [GuardState.IDLE, GuardState.ALERT, GuardState.INVESTIGATING]:
		_change_state(GuardState.CHASING)

func _on_player_lost(player: Player) -> void:
	# 丢失视野后走到丢失前最后的位置去搜索
	if target_player == player:
		last_known_position = player.global_position
		has_last_known_position = true
		target_player = null
		_change_state(GuardState.INVESTIGATING)

func _on_noise_heard(noise_position: Vector3, intensity: float, noise_type: String) -> void:
	if current_state == GuardState.CHASING or current_state == GuardState.ATTACKING:
		return

	# 记住声音来源位置
	last_known_position = noise_position
	has_last_known_position = true

	# 根据声音强度决定反应
	if intensity >= 15.0:
		_change_state(GuardState.INVESTIGATING)
		print("[Guard] 听到大声响！前往调查 - 类型：", noise_type)
	elif intensity >= 10.0:
		_change_state(GuardState.ALERT)
		print("[Guard] 听到可疑声音！进入警戒状态 - 类型：", noise_type)
	elif intensity >= 2.0 and global_position.distance_to(noise_position) < 3.0:
		_change_state(GuardState.ALERT)
		print("[Guard] 听到微弱声音！进入警戒状态 - 类型：", noise_type)

func _on_guard_died() -> void:
	print("守卫被击败")
	queue_free()
