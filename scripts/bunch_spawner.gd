extends Marker3D

enum WhatToSpawn {
	APHID
}

@export var what: WhatToSpawn = WhatToSpawn.APHID
@export var amount: int = 5

var aphid := preload("res://scenes/units/aphid.tscn")

@onready var aphids_holder: Node = $/root/World/Units/Aphids

func _ready() -> void:
	assert(aphids_holder != null, "aphids_holder missing!")
	for i in amount:
		match what:
			WhatToSpawn.APHID:
				_spawn(aphid, global_position, aphids_holder)


func _spawn(scene: PackedScene, where: Vector3, holder: Node) -> void:
	var new_node := scene.instantiate() as Node3D
	if new_node is Unit:
		(new_node as Unit).spawn_pos = where
	holder.add_child(new_node)
	new_node.global_position = where
