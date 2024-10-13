extends ControlledAntUnit
class_name AntGatherer

enum State {
	WANDERING,
	MOVING,
	GATHERING,
}

const ITEM_BONE_NAME = "Gatherer_item_"
const MAX_CARRY: int = 8

var state: State = State.WANDERING

@onready var gathering: Gathering = $Gathering


static func get_cost() -> int:
	return 15


func _ready() -> void:
	assert(gathering != null, "gathering missing!")
	super._ready()
	moving_started.connect(_on_moving_started)
	moving_finished.connect(_on_moving_ended)
	var item_bones: Array[int] = []
	for i in MAX_CARRY:
		item_bones.append(skeleton.find_bone(ITEM_BONE_NAME + str(i)))
	gathering.initialize(self, skeleton, item_bones, MAX_CARRY, 0.4, 1)


func _process(delta: float) -> void:
	super._process(delta)
	if _is_moving:
		state = State.MOVING

	_handle_wandering(delta)


func _interact(with: Interactable) -> void:
	if with is Honeydew:
		state = State.GATHERING
		gathering.start_gathering(with as Honeydew)


func _handle_wandering(delta: float) -> void:
	if state != State.WANDERING:
		return
	
	_wander(delta)


func _on_moving_ended() -> void:
	state = State.WANDERING


func _on_moving_started() -> void:
	state = State.MOVING
