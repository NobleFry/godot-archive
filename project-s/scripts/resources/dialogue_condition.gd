class_name DialogueCondition extends Resource
## 对话条件资源类
## 定义单个条件判断，支持多种条件类型

## 条件类型枚举
enum ConditionType {
	FLAG_BOOL,         ## 布尔标志位检查
	FLAG_COMPARE,      ## 数值比较
	FLAG_EXISTS,       ## 标志位是否存在
	FLAG_NOT_EXISTS,   ## 标志位是否不存在
	QUEST_STATUS,      ## 任务状态检查
	HAS_ITEM,          ## 是否拥有物品
	ITEM_COUNT,        ## 物品数量比较
	DIALOGUE_SEEN,     ## 对话是否已触发
	DIALOGUE_NOT_SEEN, ## 对话是否未触发
	NPC_DIALOGUE_SEEN, ## 特定NPC对话是否触发
}

## 比较运算符枚举
enum CompareOperator {
	EQUAL,          ## ==
	NOT_EQUAL,      ## !=
	GREATER,        ## >
	GREATER_EQUAL,  ## >=
	LESS,           ## <
	LESS_EQUAL      ## <=
}

## 条件类型
@export var condition_type: ConditionType = ConditionType.FLAG_BOOL

## 目标名称 (flag_name / quest_id / item_id / dialogue_id)
@export var target_name: String = ""

## NPC ID (仅用于 NPC_DIALOGUE_SEEN)
@export var npc_id: String = ""

## 期望的布尔值 (用于 FLAG_BOOL)
@export var expected_bool: bool = true

## 期望的任务状态 (用于 QUEST_STATUS): not_started, active, completed, failed
@export var expected_status: String = "active"

## 比较运算符 (用于 FLAG_COMPARE, ITEM_COUNT)
@export var compare_operator: CompareOperator = CompareOperator.EQUAL

## 比较值 (用于 FLAG_COMPARE, ITEM_COUNT)
@export var compare_value: int = 0

## 物品数量阈值 (用于 HAS_ITEM)
@export var item_count: int = 1

## 是否取反结果
@export var invert_result: bool = false


## 评估条件是否满足
func evaluate() -> bool:
	var result: bool = _evaluate_internal()
	if invert_result:
		result = not result
	return result


## 内部评估逻辑
func _evaluate_internal() -> bool:
	match condition_type:
		ConditionType.FLAG_BOOL:
			return GameState.is_true(target_name) == expected_bool

		ConditionType.FLAG_COMPARE:
			var flag_value: int = GameState.get_flag(target_name, 0)
			return _compare_values(flag_value, compare_value)

		ConditionType.FLAG_EXISTS:
			return GameState.has_flag(target_name)

		ConditionType.FLAG_NOT_EXISTS:
			return not GameState.has_flag(target_name)

		ConditionType.QUEST_STATUS:
			return GameState.get_quest_status(target_name) == expected_status

		ConditionType.HAS_ITEM:
			return GameState.has_item(target_name, item_count)

		ConditionType.ITEM_COUNT:
			var count: int = GameState.get_item_count(target_name)
			return _compare_values(count, compare_value)

		ConditionType.DIALOGUE_SEEN:
			return GameState.has_seen_dialogue(target_name)

		ConditionType.DIALOGUE_NOT_SEEN:
			return not GameState.has_seen_dialogue(target_name)

		ConditionType.NPC_DIALOGUE_SEEN:
			return GameState.has_seen_dialogue(target_name, npc_id)

	return false


## 数值比较辅助方法
func _compare_values(left: int, right: int) -> bool:
	match compare_operator:
		CompareOperator.EQUAL:
			return left == right
		CompareOperator.NOT_EQUAL:
			return left != right
		CompareOperator.GREATER:
			return left > right
		CompareOperator.GREATER_EQUAL:
			return left >= right
		CompareOperator.LESS:
			return left < right
		CompareOperator.LESS_EQUAL:
			return left <= right
	return false
