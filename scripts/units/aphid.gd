extends Unit
class_name Aphid

enum AphidState {
	WANDERING,
}

const HONEYDEW_INTERVAL_MIN: float = 5
const HONEYDEW_INTERVAL_MAX: float = 60
const HONEYDEW_SPAWN_SPREAD: float = 0.5
const HONEYDEWS_MAX: int = 5

var state: AphidState = AphidState.WANDERING
var honeydew_spawn_timer: float = 0
var spawned_honeydews: Dictionary = {}

var honeydew_scene := preload("res://scenes/items/honeydew.tscn")


func _ready() -> void:
	super._ready()
	_set_spawn_timer()


func _process(delta: float) -> void:
	super._process(delta)
	_handle_wandering(delta)
	_handle_honeydew_spawn(delta)


func erase_honeydew(item: Honeydew) -> void:
	var item_id := item.get_instance_id()
	if not spawned_honeydews.keys().has(item_id):
		return
	
	spawned_honeydews.erase(item_id)


func _handle_wandering(delta: float) -> void:
	if state != AphidState.WANDERING:
		return
	
	_wander(delta)


func _handle_honeydew_spawn(delta: float) -> void:
	if spawned_honeydews.size() >= HONEYDEWS_MAX:
		return

	if honeydew_spawn_timer >= 0:
		honeydew_spawn_timer -= delta
		return
	 
	audio_player.play_sound(SoundManager.pop())
	var new_honeydew := honeydew_scene.instantiate() as Honeydew
	new_honeydew.set_aphid(self)

	var new_pos := Vector3(
		randf_range(-HONEYDEW_SPAWN_SPREAD, HONEYDEW_SPAWN_SPREAD),
		new_honeydew.HEIGHT_OFFSET,
		randf_range(-HONEYDEW_SPAWN_SPREAD, HONEYDEW_SPAWN_SPREAD),
	)
	StaticNodesManager.honeydew_holder.add_child(new_honeydew)
	new_honeydew.global_position = global_position + new_pos
	_put_honeydew(new_honeydew)

	_set_spawn_timer()


func _put_honeydew(item: Honeydew) -> void:
	var item_id := item.get_instance_id()
	spawned_honeydews[item_id] = item as Honeydew


func _set_spawn_timer() -> void:
	honeydew_spawn_timer = randf_range(
			HONEYDEW_INTERVAL_MIN,
			HONEYDEW_INTERVAL_MAX,
	)
