extends CharacterBody3D

@export var walking_speed: float = 5.0
@export var running_speed: float = 10.0
@export var mouse_sensitivity: float = 0.002

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D