extends ControlledUnit
class_name AntNitwit

enum State {
	WANDERING,
	MOVING,
	GATHERING,
}

const ITEM_BONE_NAME = "Nitwit_item_"

var state: State = State.WANDERING

@onready var gathering: Gathering = $Gathering
@onready var skeleton: Skeleton3D = $AntModel/Armature/Skeleton3D


static func get_cost() -> int:
	return 5


func _ready() -> void:
	assert(gathering != null, "gathering missing!")
	assert(skeleton != null, "skeleton missing!")
	super._ready()
	moving_started.connect(_on_moving_started)
	moving_ended.connect(_on_moving_ended)
	nav_agent.navigation_finished.connect(gathering.on_nav_agent_navigation_finished)
	var item_bones: Array[int] = []
	for i in gathering.DEFAULT_MAX_CARRYING:
		item_bones.append(skeleton.find_bone(ITEM_BONE_NAME + str(i)))
	gathering.initialize(anthill, skeleton, item_bones)
	gathering.navigate_to.connect(_on_gathering_navigate_to)


func _process(delta: float) -> void:
	super._process(delta)
	if is_relocating:
		state = State.MOVING

	_handle_wandering(delta)
	_handle_gathering()


func _interact(with: Interactable) -> void:
	if with is Honeydew:
		state = State.GATHERING
		gathering.start_gathering(with as Honeydew)


func _handle_wandering(delta: float) -> void:
	if state != State.WANDERING:
		return
	
	_wander(delta)


func _handle_gathering() -> void:
	gathering.handle_gathering(showing_info)


func _on_moving_ended() -> void:
	state = State.WANDERING


func _on_moving_started() -> void:
	if state == State.GATHERING:
		gathering.stop_gathering()
	state = State.MOVING


func _on_gathering_navigate_to(pos: Vector3) -> void:
	print('_on_gathering_navigate_to')
	if state != State.GATHERING:
		return
	print('_on_gathering_navigate_to 2')

	navigate(pos)
