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

func _ready() -> void:
	for i in amount:
		var pos_offset := Vector3(
				randf_range(-gizmo_extents, gizmo_extents),
				0,
				randf_range(-gizmo_extents, gizmo_extents),
		)
		
		var scene: PackedScene
		var holder: Node
		match what:
			WhatToSpawn.APHID:
				scene = aphid
				holder = StaticNodesManager.aphids_holder
			WhatToSpawn.HONEYDEW:
				scene = honeydew
				holder = StaticNodesManager.honeydew_holder

		_spawn(
				scene,
				global_position + pos_offset,
				holder,
		)


func _spawn(scene: PackedScene, where: Vector3, holder: Node) -> void:
	var new_node := scene.instantiate() as Node3D

	if new_node is Unit:
		(new_node as Unit).spawn_pos = where
	if new_node is Honeydew:
		where.y += Honeydew.HEIGHT_OFFSET

	holder.add_child(new_node)

	new_node.global_position = where
