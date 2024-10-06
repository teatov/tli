extends Interactable
class_name Anthill

const SPAWN_RADIUS: float = 1
const DEFAULT_MAX_HONEYDEW: int = 120

var honeydew: int = 20
var max_honeydew: int = DEFAULT_MAX_HONEYDEW

var ant_nitwit := preload("res://scenes/units/ant_nitwit.tscn")

@onready var ui_origin: Node3D = $UiOrigin
@onready var nitwits_holder: Node = $/root/World/Units/Nitwits


func _ready() -> void:
	assert(ui_origin != null, "ui_origin missing!")
	assert(nitwits_holder != null, "nitwits_holder missing!")
	super._ready()


## Returns amount of honeydew that did not fit
func put_honeydew(amount: int) -> int:
	var new_honeydew_amount := honeydew + amount
	var leftover: int = 0
	if new_honeydew_amount > max_honeydew:
		honeydew = max_honeydew
		leftover = new_honeydew_amount - max_honeydew
	else:
		honeydew = new_honeydew_amount
	return leftover


func spawn_nitwit() -> void:
	var new_unit := _create_unit(ant_nitwit, AntNitwit.get_cost())
	if new_unit == null:
		return
	nitwits_holder.add_child(new_unit)


func _click() -> void:
	UiManager.anthill_info.open(self)


func _create_unit(unit_scene: PackedScene, cost: int) -> ControlledUnit:
	var new_honeydew_amount := honeydew - cost
	if new_honeydew_amount < 0:
		return null
	honeydew = new_honeydew_amount

	var spawn_pos_angle := randf_range(0, 360)
	var new_pos_offset := Vector3.BACK.rotated(Vector3.UP, spawn_pos_angle)
	var new_pos := global_position + (new_pos_offset * SPAWN_RADIUS)
	var new_unit := (
			(unit_scene.instantiate() as ControlledUnit).initialize(
					self,
					new_pos
			)
	)
	return new_unit
