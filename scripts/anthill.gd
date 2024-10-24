extends Interactable
class_name Anthill

signal buy_ant

const SPAWN_RADIUS: float = 1
const DEFAULT_MAX_HONEYDEW: int = 120

var honeydew: int = 0
var max_honeydew: int = DEFAULT_MAX_HONEYDEW

var _nitwit_scene := preload("res://scenes/units/ant_nitwit.tscn")
var _gatherer_scene := preload("res://scenes/units/ant_gatherer.tscn")

@onready var ui_origin: Node3D = $UiOrigin
@onready var deposit_point: Node3D = $DepositPoint
@onready var animation_player: AnimationPlayer = $Anthill/AnimationPlayer
@onready var audio_player: SoundEffectsPlayer = (
		$SoundEffectsPlayer
)


func _ready() -> void:
	assert(ui_origin != null, "ui_origin missing!")
	assert(audio_player != null, "audio_player missing!")
	super._ready()
	honeydew += AntNitwit.get_cost()
	spawn_nitwit(false)


func space_left() -> int:
	return max_honeydew - honeydew


## Returns amount of honeydew that did not fit.
func deposit_honeydew(amount: int) -> int:
	var new_honeydew_amount := honeydew + amount
	var leftover: int = 0
	if new_honeydew_amount > max_honeydew:
		honeydew = max_honeydew
		leftover = new_honeydew_amount - max_honeydew
	else:
		honeydew = new_honeydew_amount
	animation_player.stop()
	animation_player.play("plop_down")
	return leftover


func spawn_nitwit(ding: bool = true) -> void:
	print("spawn!")
	var new_unit := _create_unit(_nitwit_scene, AntNitwit.get_cost(), ding)
	if new_unit == null:
		return
	print("add!")
	StaticNodesManager.nitwits_holder.add_child(new_unit)


func spawn_gatherer() -> void:
	var new_unit := _create_unit(_gatherer_scene, AntGatherer.get_cost())
	if new_unit == null:
		return
	StaticNodesManager.gatherers_holder.add_child(new_unit)


func _click() -> void:
	UiManager.anthill_info.open(self)


func _create_unit(
		unit_scene: PackedScene,
		cost: int,
		ding: bool = true,
) -> ControlledUnit:
	var new_honeydew_amount := honeydew - cost
	print(new_honeydew_amount)
	if new_honeydew_amount < 0:
		return null
	honeydew = new_honeydew_amount

	var spawn_pos_angle := randf_range(0, 360)
	var new_pos_offset := Vector3.BACK.rotated(Vector3.UP, spawn_pos_angle)
	var new_pos := global_position + (new_pos_offset * SPAWN_RADIUS)
	var new_unit := (
			(unit_scene.instantiate() as ControlledUnit).initialize(
					self,
					new_pos,
			)
	)
	if ding:
		audio_player.play_sound(SoundManager.ding())
		animation_player.stop()
		animation_player.play("plop_up")

	buy_ant.emit()
	return new_unit
