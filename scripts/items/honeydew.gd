extends Interactable
class_name Honeydew

signal tween_finished

const HEIGHT_OFFSET: float = 0.1
const TWEEN_SPEED: float = 8
const TWEEN_ARC_HEIGHT: float = 0.5

var carried: bool = false

var _move_to: Vector3
var _move_from: Vector3
var _moving_timer: float = 0

var _from_aphid: Aphid

@onready var collision_shape: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	assert(collision_shape != null, "collision_shape missing!")
	super._ready()
	global_position.y = HEIGHT_OFFSET


func _process(delta: float) -> void:
	super._process(delta)
	if _moving_timer <= 0:
		if _move_to != Vector3.ZERO:
			_move_to = Vector3.ZERO
			tween_finished.emit()
		return
	_moving_timer -= delta * TWEEN_SPEED
	global_position = _move_from.bezier_interpolate(
			_move_from + Vector3.UP * TWEEN_ARC_HEIGHT,
			_move_to + Vector3.UP * TWEEN_ARC_HEIGHT,
			_move_to,
			(1 - _moving_timer),
	)
	if carried:
		hover_indicator.visible = false


func set_aphid(from: Aphid) -> void:
	_from_aphid = from


func remove_from_spawner() -> void:
	if _from_aphid == null:
		return
	_from_aphid.erase_honeydew(self)


func set_carried(on: bool) -> void:
	carried = on
	_can_interact = not carried
	collision_shape.disabled = carried


func start_tweening(to: Vector3) -> Honeydew:
	_moving_timer = 1
	_move_from = global_position
	_move_to = to
	return self
