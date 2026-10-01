extends Node3D

@export_group("Walk Bob")
@export var walk_bob_y: float = 0.035
@export var walk_bob_x: float = 0.1
@export var walk_bob_freq: float = 5

@export_group("Sprint Bob")
@export var sprint_bob_y: float = 0.1
@export var sprint_bob_x: float = 0.0
@export var sprint_bob_freq: float = 7

@export_group("Smoothing")
@export var fade_in_speed: float = 10.0
@export var fade_out_speed: float = 15.0

var _time: float = 0.0
var _bob_intensity: float = 0.0


func update(horizontal_speed: float, on_floor: bool, is_sprinting: bool) -> void:
	var target_freq: float
	var target_intensity: float
	var target_bob_y: float
	var target_bob_x: float

	if not on_floor or horizontal_speed < 0.5:
		target_freq = 0.0
		target_intensity = 0.0
		target_bob_y = walk_bob_y
		target_bob_x = walk_bob_x
	elif is_sprinting:
		target_freq = sprint_bob_freq
		target_bob_y = sprint_bob_y
		target_bob_x = sprint_bob_x
		var speed_ratio := clampf(horizontal_speed / 4.0, 0.0, 1.0)
		target_intensity = speed_ratio
	else:
		target_freq = walk_bob_freq
		target_bob_y = walk_bob_y
		target_bob_x = walk_bob_x
		var speed_ratio := clampf(horizontal_speed / 4.0, 0.0, 1.0)
		target_intensity = speed_ratio

	var delta = get_physics_process_delta_time()

	var fade_speed := fade_in_speed if _bob_intensity < target_intensity else fade_out_speed
	_bob_intensity = move_toward(_bob_intensity, target_intensity, fade_speed * delta)

	var effective_freq = target_freq if target_freq > 0.0 else walk_bob_freq
	if _bob_intensity > 0.001:
		_time += delta * effective_freq

	var t = _time

	var target_y = sin(t * 2.0) * target_bob_y * _bob_intensity
	var raw_x = (cos(t) + 1.0) * 0.5
	var target_x = raw_x * raw_x * target_bob_x * _bob_intensity

	var lerp_weight := 1.0 - exp(-fade_out_speed * delta)
	position.y = lerpf(position.y, target_y, lerp_weight)
	position.x = lerpf(position.x, target_x, lerp_weight)
