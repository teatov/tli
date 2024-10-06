extends Interactable
class_name Anthill

const SPAWN_RADIUS: float = 1

var honeydew: int = 0

var ant_nitwit := preload("res://scenes/units/ant_nitwit.tscn")

@onready var nitwits_holder: Node = $/root/World/Units/Nitwits

func _click() -> void:
	var spawn_pos_angle := randf_range(0, 360)
	var new_pos_offset := Vector3.BACK.rotated(Vector3.UP, spawn_pos_angle)
	var new_pos := global_position + (new_pos_offset * SPAWN_RADIUS)
	var new_unit := (
			(ant_nitwit.instantiate() as AntNitwit).initialize(
					self,
					new_pos
			)
	)
	nitwits_holder.add_child(new_unit)
