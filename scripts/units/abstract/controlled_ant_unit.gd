extends ControlledUnit
class_name ControlledAntUnit

const BONE_SCALE_VARIATION: float = 0.25

var _bones_to_scale: PackedStringArray = [
	"Root",
	"Body",
	"Butt",
	"Head",
	"Antenna_root_L",
	"Eye_L",
	"Mandible_L",
	"Antenna_root_R",
	"Eye_R",
	"Mandible_R",
]

@onready var skeleton: Skeleton3D = $AntModel/Armature/Skeleton3D


func _ready() -> void:
	assert(skeleton != null, "skeleton missing!")
	super._ready()
	for bone_name in _bones_to_scale:
		var bone := skeleton.find_bone(bone_name)
		var bone_transform := skeleton.get_bone_rest(bone)
		bone_transform.basis *= 1 + randf_range(
				-BONE_SCALE_VARIATION, 
				BONE_SCALE_VARIATION,
		)
		skeleton.set_bone_pose(bone, bone_transform)
