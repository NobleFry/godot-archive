extends Control

@onready var center_container: CenterContainer = $CenterContainer

func _ready() -> void:
	visible = false


func show_prompt() -> void:
	visible = true


func hide_prompt() -> void:
	visible = false
