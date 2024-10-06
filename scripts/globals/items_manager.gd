extends Node

var honeydews: Array[Honeydew] = []

var honeydew_scene := preload("res://scenes/items/honeydew.tscn")

@onready var items_holder := $/root/World/Items


func _ready() -> void:
	assert(items_holder != null, "items_holder missing!")
	spawn_a_bunch(Vector3.ZERO, 5, 0.5)


func spawn_honeydew(pos: Vector3) -> Honeydew:
	var honeydew := honeydew_scene.instantiate() as Honeydew
	items_holder.add_child(honeydew)
	honeydew.global_position = pos
	return honeydew


func spawn_a_bunch(pos: Vector3, amount: int, spread: float) -> void:
	for i in amount:
		var new_pos := pos
		new_pos.x += randf_range(-spread, spread)
		new_pos.z += randf_range(-spread, spread)
		spawn_honeydew(new_pos)
