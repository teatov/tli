extends Area3D
class_name Gathering

enum GatherState {
	PICKING_UP,
	DEPOSITING,
}

var items: Dictionary = {}
var max_carrying: int = 3
var carrying: int = 0
var state: GatherState = GatherState.PICKING_UP
var target: Honeydew


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func gather(item: Honeydew)->void:
	target = item
	state = GatherState.PICKING_UP


func _on_body_entered(item: Node3D) -> void:
	if item is not Honeydew:
		return

	var item_id := item.get_instance_id()
	if items.keys().has(item_id):
		return
	
	items[item_id] = item


func _on_body_exited(item: Node3D) -> void:
	var item_id := item.get_instance_id()
	if not items.keys().has(item_id):
		return
	
	items.erase(item_id)
