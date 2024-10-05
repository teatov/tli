extends Unit
class_name Aphid

enum AphidState {
	WANDERING,
}

const MAX_WANDER_DISTANCE: float = 5
const MIN_WANDER_INTERVAL: float = 0.25
const MAX_WANDER_INTERVAL: float = 5

var wandering_timer: float = 0
var state: AphidState = AphidState.WANDERING

@onready var wandering_center: Vector3 = global_position


func _process(delta: float) -> void:
	super._process(delta)
	_handle_wandering(delta)


func _handle_wandering(delta: float) -> void:
	if state != AphidState.WANDERING:
		return
	
	wandering_timer -= delta
	if wandering_timer <= 0:
		var new_pos_offset := Vector3(
				randf_range(-MAX_WANDER_DISTANCE, MAX_WANDER_DISTANCE),
				0,
				randf_range(-MAX_WANDER_DISTANCE, MAX_WANDER_DISTANCE),
		)
		var new_pos := wandering_center + new_pos_offset
		nav_agent.set_target_position(new_pos)
		wandering_timer = randf_range(-MIN_WANDER_INTERVAL, MAX_WANDER_INTERVAL)
