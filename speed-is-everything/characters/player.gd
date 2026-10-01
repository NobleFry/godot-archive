extends CharacterBody2D

@export_group("Base Movement")
@export var base_speed := 200.0
@export var max_speed := 1000.0
@export var speed_build_up_rate := 10.0
@export var acceleration := 2000.0
@export var deceleration := 2000.0

@export_group("Jump")
@export var base_jump_velocity := -400.0
@export var max_jump_velocity := -1000.0
@export var gravity_scale := 1.0
@export var gravity_fast_fall_scale := 4

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var speed_label: Label = $DebugLayer/DebugUI/Speed
@onready var jump_height_label: Label = $DebugLayer/DebugUI/JumpHeight

enum State { IDLE, RUN, JUMP, FALL }
var current_state: State = State.IDLE

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_target_speed: float = 200.0

var last_jump_velocity: float = 0.0
var last_speed_ratio: float = 0.0 

# 死亡变量
var dead := false:
	set(value):
		dead = value
		if value == true:
			_trigger_death()

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reload"):
		dead = true

	if event.is_action_pressed("toggle_mouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if dead:
		return

	var input_dir = Input.get_axis("left", "right")

	_update_state(input_dir)
	_handle_gravity(delta)
	_handle_movemont(delta, input_dir)
	_handle_animation(input_dir)
	_handle_debug()

	move_and_slide()

# 更新状态（仅用于动画）
func _update_state(input_dir: float) -> void:
	if is_on_floor():
		if Input.is_action_pressed("jump"):
			current_state = State.JUMP
		elif input_dir:
			current_state = State.RUN
		else:
			current_state = State.IDLE
	else:
		if velocity.y < 0:
			current_state = State.JUMP
		else:
			current_state = State.IDLE

# 应用重力
func _handle_gravity(delta: float) -> void:
	if not is_on_floor():
		# 按住下键加速坠落
		if Input.is_action_pressed("down"):
			velocity.y += gravity * gravity_fast_fall_scale * delta
		else:
			velocity.y += gravity * gravity_scale * delta

# 应用移动
func _handle_movemont(delta: float, input_dir: float) -> void:
	# 水平移动逻辑
	if input_dir != 0:
		current_target_speed = move_toward(current_target_speed, max_speed, speed_build_up_rate * delta)
		velocity.x = move_toward(velocity.x, input_dir * current_target_speed, acceleration * delta)
	else:
		current_target_speed = base_speed
		velocity.x = 0.0 
	# 跳跃逻辑
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		var raw_ratio = clampf(abs(velocity.x) / max_speed, 0.0, 1.0)
		var speed_ratio = pow(raw_ratio, 2)
		var dynamic_jump_velocity = lerpf(base_jump_velocity, max_jump_velocity, speed_ratio)
		velocity.y = dynamic_jump_velocity

		last_jump_velocity = abs(velocity.y)
		last_speed_ratio = raw_ratio * 100.0

		print("起跳速度 Y: %.1f | 当前水平速度占比: %.1f%%" % [velocity.y, raw_ratio * 100])
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.1

# 应用动画
func _handle_animation(input_dir: float):
	if input_dir > 0.0:
		animated_sprite.flip_h = false
	elif input_dir < 0.0:
		animated_sprite.flip_h = true

	match current_state:
		State.IDLE:
			animated_sprite.play("idle")
		State.RUN:
			animated_sprite.play("run")
		State.JUMP:
			animated_sprite.play("jump")

func _handle_debug() -> void:
	var current_speed = abs(velocity.x)
	
	speed_label.text = "speed: " + str(round(current_speed))
	jump_height_label.text = "last jump height: " + str(round(last_jump_velocity))

# 处理死亡
func _trigger_death() -> void:
	velocity = Vector2.ZERO
	# await get_tree().create_timer(0.5).timeout
	get_tree().call_deferred("reload_current_scene")
