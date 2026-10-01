extends Node3D

@onready var progress_bar: ProgressBar = $SubViewport/ProgressBar
@onready var sprite: Sprite3D = $Sprite3D

var health_tween: Tween

func _ready() -> void:
	visible = true

func update_health(current_val: float, max_val: float) -> void:
	if not progress_bar: return

	progress_bar.max_value = max_val

	if health_tween:
		health_tween.kill()

	health_tween = create_tween()
	health_tween.tween_property(progress_bar, "value", current_val, 0.3) \
	.set_trans(Tween.TRANS_QUART) \
	.set_ease(Tween.EASE_OUT)
	
	# 自动显隐：不满血则显示
	# visible = current_val < max_val
