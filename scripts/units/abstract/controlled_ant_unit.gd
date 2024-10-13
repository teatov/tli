extends ControlledUnit
class_name ControlledAntUnit

@onready var skeleton: Skeleton3D = $AntModel/Armature/Skeleton3D


func _ready() -> void:
	assert(skeleton != null, "skeleton missing!")
	super._ready()
