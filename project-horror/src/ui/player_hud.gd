extends CanvasLayer

@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/HealthBar

var health_tween: Tween

func update_health(current_val: float, max_val: float) -> void:
	if not health_bar: return

	health_bar.max_value = max_val

	# 停止上一个补间
	if health_tween:
		health_tween.kill()
	
	health_tween = create_tween()
	health_tween.tween_property(health_bar, "value", current_val, 0.3) \
		.set_trans(Tween.TRANS_QUART) \
		.set_ease(Tween.EASE_OUT)
