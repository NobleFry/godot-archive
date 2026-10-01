extends Node
class_name BatteryComponent

signal battery_depleted
signal battery_changed(current_percentage)

@export_group("Battery Capacity")
@export var max_battery: float = 100.0
@export var base_drain_rate: float = 0.5
@export var scan_drain: float = 15.0
@export var drain_multiplier: float = 1.0

var current_battery: float
var is_draining: bool = false

func _ready() -> void:
	current_battery = max_battery

func _process(delta: float) -> void:
	if is_draining and current_battery > 0:
		drain(base_drain_rate * drain_multiplier * delta)

func start_draining() -> void:
	is_draining = true

func stop_draining() -> void:
	is_draining = false

func drain(amount: float) -> void:
	if current_battery <= 0.0:
		return

	current_battery -= amount
	current_battery = maxf(0.0, current_battery)
	battery_changed.emit(current_battery / max_battery)
	
	if current_battery <= 0.0:
		is_draining = false
		battery_depleted.emit()

func recharge(amount: float) -> void:
	current_battery += amount
	current_battery = minf(max_battery, current_battery)
	battery_changed.emit(current_battery / max_battery)

func set_drain_multiplier(value: float) -> void:
	drain_multiplier = maxf(0.0, value)
