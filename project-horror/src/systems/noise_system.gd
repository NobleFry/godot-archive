extends Node

# 让任何角色发出声音时触发
signal noise_emitted(noise_position: Vector3, intensity: float, noise_type: String)

# 发出噪音的方法
func emit_noise(noise_position: Vector3, intensity: float, noise_type: String) -> void:
	noise_emitted.emit(noise_position, intensity, noise_type)