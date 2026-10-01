# 负责监听 PlayerInputController 发出的信号
# 管理武器列表 weapons 数组和当前选中的武器
# 负责协调和其他系统（噪音，UI）之前的交互

extends Node3D
class_name WeaponManager

var input_controller: PlayerInputController
var noise_emitter: Node

var weapons: Array[WeaponBase] = []
var active_weapon: WeaponBase
var current_index: int = 0

func _ready() -> void:
	# 检查是否存在 PlayerInputController 和 NoiseEmitter
	# 这些是可选组件，因为 WeaponManager 可能会挂载在敌人身上
	input_controller = get_node_or_null("%PlayerInputController")
	noise_emitter = get_node_or_null("%NoiseEmitter")

	for child in get_children():
		if child is WeaponBase:
			weapons.append(child)
			child.deactivate()

	if weapons.size() > 0:
		switch_weapon(0)
	
	# 仅在 input_controller 存在时绑定输入信号（通常是玩家）
	if input_controller:
		input_controller.attack_pressed.connect(trigger_attack)
		input_controller.reload_pressed.connect(trigger_reload)
		input_controller.change_weapon_next.connect(switch_next)
		input_controller.change_weapon_prev.connect(switch_prev)
	else:
		# 处理非玩家控制情况（如由 AI 控制或通过代码调用）
		pass

# 触发攻击
func trigger_attack() -> void:
	if active_weapon:
		active_weapon.attack()
		if noise_emitter and noise_emitter.has_method("emit_custom_noise"):
			noise_emitter.emit_custom_noise(active_weapon.noise_intensity_on_attack, "attack_noise")

# 触发换弹
func trigger_reload() -> void:
	if active_weapon:
		active_weapon.reload()
		if noise_emitter and noise_emitter.has_method("emit_custom_noise"):
			noise_emitter.emit_custom_noise(active_weapon.noise_intensity_on_reload, "reload_noise")

# 切换下一个武器
func switch_next() -> void:
	if weapons.size() <= 1: return
	var next_index = (current_index + 1) % weapons.size()
	switch_weapon(next_index)

# 切换上一个武器
func switch_prev() -> void:
	if weapons.size() <= 1: return
	var prev_index = (current_index - 1 + weapons.size()) % weapons.size()
	switch_weapon(prev_index)

# 切换到指定索引的武器
func switch_weapon(index: int) -> void:
	if active_weapon:
		active_weapon.deactivate()

	current_index = index # 更新索引记录
	active_weapon = weapons[index]
	active_weapon.activate()
	print("切换到武器: ", active_weapon.weapon_name)
