extends ControlledUnit
class_name AntNitwit

enum AntNitwitState {
	WANDERING,
	MOVING,
}

var state: AntNitwitState = AntNitwitState.WANDERING


func _ready() -> void:
	super._ready()
	moving_started.connect(_on_moving_started)
	moving_ended.connect(_on_moving_ended)


func _process(delta: float) -> void:
	super._process(delta)
	if moving_to_target:
		state = AntNitwitState.MOVING

	_handle_wandering(delta)


static func get_cost() -> int:
	return 5


func _handle_wandering(delta: float) -> void:
	if state != AntNitwitState.WANDERING:
		return
	
	_wander(delta)


func _on_moving_ended() -> void:
	state = AntNitwitState.WANDERING


func _on_moving_started() -> void:
	state = AntNitwitState.MOVING
