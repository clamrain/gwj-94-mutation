extends Node3D
class_name HandInventory

@export var item_switch_duration: float = 0.5

var item_list: Array[Node3D] = []
var cursor := 0

const ACTIVE_POSITION = Vector3(0.0, 0.0, 0.0)
const PASSIVE_POSITION = Vector3(0.0, -0.3, 0.3)

@onready var active_item_node = $ItemNodeA
@onready var passive_item_node = $ItemNodeB

func _ready():
	passive_item_node.position = PASSIVE_POSITION

func get_held_item():
	if not item_list.is_empty():
		return item_list[cursor]
	else:
		return null

func init_item():
	if not item_list.is_empty():
		if active_item_node.get_child_count() > 0 and active_item_node.get_child(0) == item_list[cursor]:
			return
		_switch_item(item_list[cursor])

func erase_item(item: Node3D):
	if item_list.has(item):
		item_list.erase(item)
	cursor = max(cursor-1,0)
	init_item()

func _input(event: InputEvent) -> void:
	if item_list.size() < 2:
		return
	if event.is_action_released("previous_item"):
		cursor = posmod(cursor - 1, item_list.size())
		_switch_item(item_list[cursor])
	elif event.is_action_released("next_item"):
		cursor = posmod(cursor + 1, item_list.size())
		_switch_item(item_list[cursor])

func _switch_item(new_item: Node3D):
	if new_item.get_parent():
		new_item.get_parent().remove_child(new_item)
	if passive_item_node.get_child_count() > 0:
		passive_item_node.remove_child(passive_item_node.get_child(0))
	passive_item_node.add_child(new_item)
	new_item.scale = Vector3.ONE * 0.3
	create_tween().tween_property(passive_item_node, "position", ACTIVE_POSITION, item_switch_duration)
	create_tween().tween_property(active_item_node, "position", PASSIVE_POSITION, item_switch_duration)
	
	var swap = passive_item_node
	passive_item_node = active_item_node
	active_item_node = swap
