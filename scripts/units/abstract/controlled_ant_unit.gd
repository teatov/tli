extends ControlledUnit
class_name ControlledAntUnit

@onready var _skeleton: Skeleton3D = $AntModel/Armature/Skeleton3D


func _ready() -> void:
	assert(_skeleton != null, "_skeleton missing!")
	super._ready()
