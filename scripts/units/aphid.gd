extends Unit
class_name Aphid

enum State {
	WANDERING,
}

const BONE_SCALE_VARIATION: float = 0.25

const HONEYDEW_INTERVAL_MIN: float = 5
const HONEYDEW_INTERVAL_MAX: float = 60
const HONEYDEW_SPAWN_SPREAD: float = 0.5
const HONEYDEWS_MAX: int = 5

var state: State = State.WANDERING
var honeydew_spawn_timer: float = 0
var spawned_honeydews: Dictionary = {}

var honeydew_scene := preload("res://scenes/items/honeydew.tscn")

var _bones_to_scale: PackedStringArray = [
	"Root",
	"Antenna_root_L",
	"Eye_L",
	"Antenna_root_R",
	"Eye_R",
]

@onready var skeleton: Skeleton3D = $AphidModel/Armature/Skeleton3D


func _ready() -> void:
	assert(skeleton != null, "skeleton missing!")
	super._ready()
	_set_spawn_timer()
	for bone_name in _bones_to_scale:
		var bone := skeleton.find_bone(bone_name)
		var bone_transform := skeleton.get_bone_pose(bone)
		bone_transform.basis *= 1 + randf_range(
				-BONE_SCALE_VARIATION, 
				BONE_SCALE_VARIATION,
		)
		skeleton.set_bone_pose_scale(bone, Vector3.ZERO)


func _process(delta: float) -> void:
	super._process(delta)
	_handle_wandering(delta)
	_handle_honeydew_spawn(delta)


func erase_honeydew(item: Honeydew) -> void:
	var item_id := item.get_instance_id()
	if not spawned_honeydews.keys().has(item_id):
		return
	
	spawned_honeydews.erase(item_id)


func _handle_wandering(delta: float) -> void:
	if state != State.WANDERING:
		return
	
	_wander(delta)


func _handle_honeydew_spawn(delta: float) -> void:
	if spawned_honeydews.size() >= HONEYDEWS_MAX:
		return

	if honeydew_spawn_timer >= 0:
		honeydew_spawn_timer -= delta
		return
	
	var new_honeydew := honeydew_scene.instantiate() as Honeydew
	new_honeydew.set_aphid(self)

	var new_pos := Vector3(
		randf_range(-HONEYDEW_SPAWN_SPREAD, HONEYDEW_SPAWN_SPREAD),
		new_honeydew.HEIGHT_OFFSET,
		randf_range(-HONEYDEW_SPAWN_SPREAD, HONEYDEW_SPAWN_SPREAD),
	)
	StaticNodesManager.honeydew_holder.add_child(new_honeydew)
	new_honeydew.global_position = global_position + new_pos
	_put_honeydew(new_honeydew)

	_set_spawn_timer()


func _put_honeydew(item: Honeydew) -> void:
	var item_id := item.get_instance_id()
	spawned_honeydews[item_id] = item as Honeydew


func _set_spawn_timer() -> void:
	honeydew_spawn_timer = randf_range(
			HONEYDEW_INTERVAL_MIN,
			HONEYDEW_INTERVAL_MAX,
	)
