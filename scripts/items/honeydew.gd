extends Interactable
class_name Honeydew

signal moved

const HEIGHT_OFFSET: float = 0.1
const MOVE_SPEED: float = 8
const MOVE_ARC_HEIGHT: float = 0.5

var carried: bool = false
var move_to: Vector3
var move_from: Vector3
var moving_timer: float = 0

@onready var collision_shape: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	assert(collision_shape != null, "collision_shape missing!")
	super._ready()
	global_position.y = HEIGHT_OFFSET


func _process(delta: float) -> void:
	super._process(delta)
	if moving_timer <= 0:
		if move_to != Vector3.ZERO:
			move_to = Vector3.ZERO
			moved.emit()
		return
	moving_timer -= delta * MOVE_SPEED
	global_position = move_from.bezier_interpolate(
			move_from + Vector3.UP * MOVE_ARC_HEIGHT,
			move_to + Vector3.UP * MOVE_ARC_HEIGHT,
			move_to,
			(1 - moving_timer),
	)
	if carried:
		hover_indicator.visible = false


func set_carried(on: bool) -> void:
	carried = on
	can_interact = not carried
	collision_shape.disabled = carried


func start_moving(to: Vector3) -> Honeydew:
	moving_timer = 1
	move_from = global_position
	move_to = to
	return self
