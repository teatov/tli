extends ControlledUnit
class_name AntNitwit

enum AntNitwitState {
	WANDERING,
	MOVING,
	GATHERING,
}

var state: AntNitwitState = AntNitwitState.WANDERING

@onready var gathering: Gathering = $Gathering


static func get_cost() -> int:
	return 5


func _ready() -> void:
	assert(gathering != null, "gathering missing!")
	super._ready()
	moving_started.connect(_on_moving_started)
	moving_ended.connect(_on_moving_ended)
	nav_agent.navigation_finished.connect(gathering.on_nav_agent_navigation_finished)
	gathering.initialize(anthill)
	gathering.target_set.connect(_on_gathering_target_set)
	gathering.stop_gathering.connect(_on_gathering_stop)


func _process(delta: float) -> void:
	super._process(delta)
	if moving_to_target:
		state = AntNitwitState.MOVING

	_handle_wandering(delta)
	_handle_gathering()


func _interact(with: Interactable) -> void:
	if with is Honeydew:
		state = AntNitwitState.GATHERING
		gathering.go_gather(with as Honeydew)


func _handle_wandering(delta: float) -> void:
	if state != AntNitwitState.WANDERING:
		return
	
	_wander(delta)


func _handle_gathering() -> void:
	gathering.handle_gathering(state != AntNitwitState.GATHERING)


func _on_moving_ended() -> void:
	state = AntNitwitState.WANDERING


func _on_moving_started() -> void:
	if state == AntNitwitState.GATHERING:
		gathering.stop_all_gathering()
	state = AntNitwitState.MOVING


func _on_gathering_target_set(pos: Vector3) -> void:
	if state != AntNitwitState.GATHERING:
		return

	nav_agent.set_target_position(pos)


func _on_gathering_stop() -> void:
	state = AntNitwitState.WANDERING
