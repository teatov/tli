extends Marker3D
class_name BunchSpawner

enum WhatToSpawn {
	APHID,
	HONEYDEW,
}

@export var what: WhatToSpawn = WhatToSpawn.APHID
@export var amount: int = 5

var aphid := preload("res://scenes/units/aphid.tscn")
var honeydew := preload("res://scenes/items/honeydew.tscn")

@onready var aphids_holder: Node = $/root/World/Units/Aphids
@onready var honeydew_holder: Node = $/root/World/Items/Honeydew

func _ready() -> void:
	assert(aphids_holder != null, "aphids_holder missing!")
	for i in amount:
		var pos_offset := Vector3(
				randf_range(-gizmo_extents, gizmo_extents),
				0,
				randf_range(-gizmo_extents, gizmo_extents),
		)
		match what:
			WhatToSpawn.APHID:
				_spawn(aphid, global_position + pos_offset, aphids_holder)
			WhatToSpawn.HONEYDEW:
				_spawn(honeydew, global_position + pos_offset, honeydew_holder)


func _spawn(scene: PackedScene, where: Vector3, holder: Node) -> void:
	var new_node := scene.instantiate() as Node3D

	if new_node is Unit:
		(new_node as Unit).spawn_pos = where
	if new_node is Honeydew:
		where.y += Honeydew.HEIGHT_OFFSET

	holder.add_child(new_node)

	new_node.global_position = where
