extends Unit
class_name Aphid

enum AphidState {
	WANDERING,
}

var state: AphidState = AphidState.WANDERING


func _process(delta: float) -> void:
	super._process(delta)
	_handle_wandering(delta)


func _handle_wandering(delta: float) -> void:
	if state != AphidState.WANDERING:
		return
	
	_wander(delta)
