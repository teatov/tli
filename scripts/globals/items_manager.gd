extends Node

var honeydews: Dictionary = {}

var honeydew_scene := preload("res://scenes/items/honeydew.tscn")

@onready var items_holder := $/root/World/Items


func _ready() -> void:
	assert(items_holder != null, "items_holder missing!")


func spawn_honeydew(pos: Vector3) -> Honeydew:
	var honeydew := honeydew_scene.instantiate() as Honeydew
	honeydew.global_position = pos
	items_holder.add_child(honeydew)
	return honeydew


func spawn_a_bunch(pos: Vector3, amount: int, spread: float) -> void:
	for i in amount:
		var new_pos := pos
		new_pos.x += randf_range(-spread, spread)
		new_pos.z += randf_range(-spread, spread)
		var new_honeydew := spawn_honeydew(new_pos)
		put_honeydew(new_honeydew)


func put_honeydew(item: Honeydew) -> void:
	var item_id := item.get_instance_id()
	if honeydews.keys().has(item_id):
		return
	honeydews[item_id] = item


func erase_honeydew(item: Honeydew) -> void:
	var item_id := item.get_instance_id()
	if not honeydews.keys().has(item_id):
		return
	honeydews.erase(item_id)
