extends Marker3D
class_name BunchSpawner
## Spawns a bunch of specified nodes upon entering the tree

enum WhatToSpawn {
	APHID,
	HONEYDEW,
}

@export var _what: WhatToSpawn = WhatToSpawn.APHID
@export var _amount: int = 5

var _aphid_scene := preload("res://scenes/units/aphid.tscn")
var _honeydew_scene := preload("res://scenes/items/honeydew.tscn")

func _ready() -> void:
	for i in _amount:
		var pos_offset := Vector3(
				randf_range(-gizmo_extents, gizmo_extents),
				0,
				randf_range(-gizmo_extents, gizmo_extents),
		)
		
		var scene: PackedScene
		var holder: Node
		match _what:
			WhatToSpawn.APHID:
				scene = _aphid_scene
				holder = StaticNodesManager.aphids_holder
			WhatToSpawn.HONEYDEW:
				scene = _honeydew_scene
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
