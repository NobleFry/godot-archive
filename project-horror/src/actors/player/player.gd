extends CharacterBody3D
class_name Player

@export_group("Movement Parameters")
@export var walk_speed: float = 2.5
@export var sprint_speed: float = 4.0
@export var crouch_speed: float = 2.0
@export var jump_velocity: float = 3.0
@export var acceleration: float = 50.0
@export var air_acceleration: float = 20.0
@export var friction: float = 40.0
@export var air_friction: float = 0.5
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_group("Player Settings")
@export var player_height: float = 1.8 
 
# @onready var weapon_manager: WeaponManager = $CameraPivot/FirstPersonCamera/WeaponManager
@onready var health_component: HealthComponent = $HealthComponent
@onready var player_hud = $PlayerHUD
# @onready var noise_emitter: Node = $NoiseEmitter
@onready var input_controller: PlayerInputController = %PlayerInputController

# 共享状态并设置初始值
var is_crouching: bool = false
var is_sprinting: bool = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	setup_height()

	health_component.died.connect(_on_player_died)
	health_component.health_changed.connect(player_hud.update_health)
	
	input_controller.toggle_cursor_requested.connect(_on_toggle_cursor)

func _on_toggle_cursor():
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func setup_height():
	# 将碰撞体和网格设置为唯一，防止修改影响其他实例共享资源，并自适应高度
	var mesh_instance = $Visuals/MeshInstance3D
	mesh_instance.mesh = mesh_instance.mesh.duplicate()
	mesh_instance.mesh.height = player_height
	
	var tall_shape = $TallShape
	tall_shape.shape = tall_shape.shape.duplicate()
	tall_shape.shape.height = player_height
	
	var short_shape = $ShortShape
	short_shape.shape = short_shape.shape.duplicate()
	short_shape.shape.height = player_height / 2.0
	short_shape.position.y = - player_height / 4.0
	
	var head_check_shape = $HeadCheckArea/CollisionShape3D
	head_check_shape.shape = head_check_shape.shape.duplicate()
	head_check_shape.shape.height = player_height / 2.0
	head_check_shape.position.y = player_height / 4.0

func update_stature(p_is_crouching: bool, delta: float) -> void:
	if has_node("TallShape") and has_node("ShortShape"):
		$TallShape.disabled = p_is_crouching
		$ShortShape.disabled = !p_is_crouching

	if has_node("Visuals"):
		var target_scale = 0.6 if p_is_crouching else 1.0
		$Visuals.scale.y = lerpf($Visuals.scale.y, target_scale, 10.0 * delta)
		

# 检查头顶是否有空间站起
func can_stand_up() -> bool:
	if not is_crouching: return true
	var bodies = $HeadCheckArea.get_overlapping_bodies()
	for body in bodies:
		if body != self:
			return false
	return true

func _on_player_died() -> void:
	print("player died,reset the game")
	get_tree().call_deferred("reload_current_scene")
