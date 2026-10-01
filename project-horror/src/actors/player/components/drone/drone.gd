extends CharacterBody3D
class_name Drone

enum DroneMode {FIRST_PERSON, THIRD_PERSON_FOLLOW, FREE_FLIGHT, STANDBY}

@export var max_switch_distance := 2.0
@export var follow_offset := Vector3(0, 1.5, -2.0)
@export var low_drain_multiplier := 0.2
@export var follow_drain_multiplier := 0.7

@onready var drone_camera: Camera3D = $DroneCamera
@onready var battery: BatteryComponent = $BatteryComponent
@onready var state_root: Node = $States
@onready var view_state_manager: ViewStateManager = $"../ViewStateManager"

@onready var states = {
	DroneMode.FIRST_PERSON: state_root.get_node("FirstPersonState"),
	DroneMode.THIRD_PERSON_FOLLOW: state_root.get_node("ThirdPersonFollowState"),
	DroneMode.FREE_FLIGHT: state_root.get_node("FreeFlightState"),
	DroneMode.STANDBY: state_root.get_node("StandbyState"),
}

var current_mode: int = DroneMode.FIRST_PERSON
var last_active_mode: int = DroneMode.THIRD_PERSON_FOLLOW
var standby_position: Vector3

var player: CharacterBody3D
var input_controller: PlayerInputController

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D
	input_controller = get_tree().get_first_node_in_group("player_input") as PlayerInputController
	if not player:
		push_warning("Player not found in the scene tree. Drone will not function properly.")
		player = null

	if not input_controller:
		push_warning("PlayerInputController not found in the scene tree. Drone will not receive input.")
		input_controller = null

	if input_controller:
		input_controller.drone_mode_toggle_requested.connect(_on_drone_mode_toggle_requested)
		input_controller.drone_deploy_requested.connect(_on_drone_deploy_requested)

	# 给各个状态节点里的drone和player变量赋值
	for s in states.values():
		s.drone = self
		s.player = player
	
	enter_mode(DroneMode.FIRST_PERSON)

# 检测是否可以切换模式
func request_switch(target_mode: int) -> void:
	if not can_switch_mode():
		return
	enter_mode(target_mode)

func enter_mode(target_mode: int) -> void:
	print("Drone: switch from", current_mode, "to", target_mode)
	if states.has(current_mode):
		states[current_mode].exit()

	if target_mode != DroneMode.FIRST_PERSON:
		last_active_mode = target_mode
	
	current_mode = target_mode
	states[current_mode].enter()

	match target_mode:
		DroneMode.FIRST_PERSON:
			view_state_manager.switch_to_first_person()
		DroneMode.THIRD_PERSON_FOLLOW:
			view_state_manager.switch_to_third_person()
		DroneMode.FREE_FLIGHT:
			view_state_manager.switch_to_free_drone()

# 通用约束检查：无人机与玩家的距离必须在max_switch_distance内
func can_switch_mode() -> bool:
	if not player:
		return false

	if player.global_position.distance_to(global_position) > max_switch_distance:
		return false

	var space_state = get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		player.global_position,
		global_position
	)
	query.exclude = [player, self]

	var hit = space_state.intersect_ray(query)
	print("Raycast hit: ", hit)
	print("player_pos:", player.global_position)                     
	print("drone_pos:", global_position)  
	
	return hit.is_empty() # 如果射线没有被任何物体阻挡，则允许切换

# 供外部调用的接口：切换部署状态（部署/收回）
func toggle_deploy() -> void:
	if current_mode == DroneMode.FIRST_PERSON:
		enter_mode(last_active_mode)
	else:
		enter_mode(DroneMode.FIRST_PERSON)

func toggle_follow_free() -> void:
	if current_mode == DroneMode.THIRD_PERSON_FOLLOW:
		enter_mode(DroneMode.FREE_FLIGHT)
	elif current_mode == DroneMode.FREE_FLIGHT:
		enter_mode(DroneMode.THIRD_PERSON_FOLLOW)

func _on_drone_mode_toggle_requested() -> void:
	toggle_follow_free()

func _on_drone_deploy_requested() -> void:
	if can_switch_mode():
		toggle_deploy()
	else:
		print("can't switch")
