extends ControlledUnit
class_name AntGatherer

enum AntGathererState {
	WANDERING,
	MOVING,
	GATHERING,
}

var state: AntGathererState = AntGathererState.WANDERING

@onready var gathering: Gathering = $Gathering


static func get_cost() -> int:
	return 15


func _ready() -> void:
	assert(gathering != null, "gathering missing!")
	super._ready()
	moving_started.connect(_on_moving_started)
	moving_ended.connect(_on_moving_ended)
	nav_agent.navigation_finished.connect(gathering.on_nav_agent_navigation_finished)
	gathering.initialize(anthill, 8, 0.4, 1)
	gathering.target_set.connect(_on_gathering_target_set)
	gathering.stop_gathering.connect(_on_gathering_stop)


func _process(delta: float) -> void:
	super._process(delta)
	if moving_to_target:
		state = AntGathererState.MOVING

	_handle_wandering(delta)
	_handle_gathering()


func _interact(with: Interactable) -> void:
	if with is Honeydew:
		state = AntGathererState.GATHERING
		gathering.go_gather(with as Honeydew)


func _handle_wandering(delta: float) -> void:
	if state != AntGathererState.WANDERING:
		return
	
	_wander(delta)


func _handle_gathering() -> void:
	gathering.handle_gathering(state != AntGathererState.GATHERING)


func _on_moving_ended() -> void:
	state = AntGathererState.WANDERING


func _on_moving_started() -> void:
	if state == AntGathererState.GATHERING:
		gathering.stop_all_gathering()
	state = AntGathererState.MOVING


func _on_gathering_target_set(pos: Vector3) -> void:
	if state != AntGathererState.GATHERING:
		return

	if pos != Vector3.ZERO:
		nav_agent.set_target_position(pos)
	else:
		nav_agent.set_target_position(anthill.global_position)


func _on_gathering_stop() -> void:
	state = AntGathererState.WANDERING
