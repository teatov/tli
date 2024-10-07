extends Area3D
class_name Gathering

signal navigate_to(pos: Vector3)

const DEFAULT_MAX_CARRYING = 3
const DEFAULT_DROP_INTERVAL = 0.25
const DEFAULT_PICKUP_INTERVAL = 0.5
const DROP_SPREAD: float = 0.1
const ANTHILL_DEPOSIT_RADIUS: float = 0.5

enum GatherState {
	AWAITING,
	PICKING_UP,
	DEPOSITING,
	STOP,
}

var state: GatherState = GatherState.STOP

var nearby_items: Dictionary = {}
var carrying_items: Array[Honeydew] = []
var max_carrying: int = DEFAULT_MAX_CARRYING

var target: Honeydew
var anthill: Anthill
var skeleton: Skeleton3D

var drop_interval: float = DEFAULT_DROP_INTERVAL
var pickup_interval: float = DEFAULT_PICKUP_INTERVAL
var item_bones: Array[int] = []
var showing_after_set: bool = false

@onready var gathering_center: Vector3 = global_position
@onready var collision_shape: CollisionShape3D = $NearbyItemsSearch
@onready var radius_indicator: VisualInstance3D = (
		$NearbyItemsSearch/GatheringRadius
)
@onready var audio_player: AudioStreamPlayerPolyphonic = (
		$AudioStreamPlayerPolyphonic
)


func _ready() -> void:
	assert(collision_shape != null, "collision_shape missing!")
	assert(radius_indicator != null, "radius_indicator missing!")
	assert(audio_player != null, "audio_player missing!")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	for i in range(carrying_items.size()):
		var item := carrying_items[i]
		item.global_position = _get_nth_pile_pos(i)

	if target != null:
		DebugManager.circle(target.global_position)


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventMouseButton and showing_after_set:
		var button_event := event as InputEventMouseButton
		if not button_event.pressed:
			return
		if (
				button_event.button_index == MOUSE_BUTTON_LEFT
				or button_event.button_index == MOUSE_BUTTON_RIGHT
		):
			showing_after_set = false


func initialize(
		from: Anthill,
		skeleton_3d: Skeleton3D,
		bones: Array[int],
		max_carry: int = DEFAULT_MAX_CARRYING,
		drop_interv: float = DEFAULT_DROP_INTERVAL,
		pickup_interv: float = DEFAULT_PICKUP_INTERVAL,
) -> void:
	anthill = from
	max_carrying = max_carry
	drop_interval = drop_interv
	pickup_interval = pickup_interv
	skeleton = skeleton_3d
	item_bones = bones


func handle_gathering(showing_info: bool) -> void:
	collision_shape.global_position = gathering_center
	collision_shape.global_rotation = Vector3.ZERO

	radius_indicator.visible = (
			(state != GatherState.STOP and showing_info)
			or showing_after_set
	)


func start_gathering(item: Honeydew) -> void:
	gathering_center = item.global_position
	showing_after_set = true
	state = GatherState.AWAITING
	_go_pick_up(item)


func stop_gathering() -> void:
	state = GatherState.STOP
	target = null


func on_nav_agent_navigation_finished() -> void:
	if state == GatherState.PICKING_UP:
		_pick_up()

	if (
			state == GatherState.DEPOSITING
			and global_position.distance_to(anthill.global_position) < 1
	):
		_deposit()


func _go_pick_up(item: Honeydew) -> void:
	state = GatherState.AWAITING
	if anthill.space_left() <= 0:
		return
	if carrying_items.size() >= max_carrying:
		_go_deposit()
		return
	target = item
	state = GatherState.PICKING_UP
	navigate_to.emit(item.global_position)


func _go_deposit() -> void:
	state = GatherState.DEPOSITING
	var dir := anthill.global_position.direction_to(global_position)
	navigate_to.emit(
			anthill.global_position
			+ dir
			* ANTHILL_DEPOSIT_RADIUS
	)


func _get_nth_pile_pos(n: int) -> Vector3:
	return skeleton.to_global(skeleton.get_bone_global_pose(item_bones[n]).origin)


func _pick_up() -> void:
	var nearest := _find_nearest(nearby_items.values())
	if target == null or target.carried:
		state = GatherState.AWAITING
		if nearest != null:
			_go_pick_up(nearest)
		elif carrying_items.size() > 0:
			_go_deposit()
		return

	carrying_items.append(target)
	target.set_carried(true)
	audio_player.play_polyphonic(SoundManager.swoosh())
	await target.start_moving(
			_get_nth_pile_pos(carrying_items.size() - 1)
	).moved
	audio_player.play_polyphonic(SoundManager.pop())

	await get_tree().create_timer(pickup_interval).timeout
	if carrying_items.size() >= max_carrying or nearest == null:
		_go_deposit()
		return

	_go_pick_up(nearest)


func _deposit() -> void:
	await get_tree().create_timer(0.5).timeout
	while carrying_items.size() > 0:
		if state != GatherState.DEPOSITING:
			return

		if anthill.space_left() <= 0:
			state = GatherState.AWAITING
			await _drop_everything()
			return

		var item := carrying_items.pop_back() as Honeydew
		audio_player.play_polyphonic(SoundManager.swoosh())
		await item.start_moving(anthill.global_position).moved
		audio_player.play_polyphonic(SoundManager.tok())
		item.remove_from_spawner()
		_erase_honeydew(item)
		item.queue_free()
		anthill.deposit_honeydew(1)
		await get_tree().create_timer(drop_interval).timeout
	
	var nearest := _find_nearest(nearby_items.values())
	if nearest != null:
		_go_pick_up(nearest)
		return
	
	state = GatherState.AWAITING
	navigate_to.emit(gathering_center)


func _drop_everything() -> void:
	while carrying_items.size() > 0:
		var item := carrying_items.pop_back() as Honeydew
		var new_pos := Vector3(
			randf_range(-DROP_SPREAD, DROP_SPREAD),
			Honeydew.HEIGHT_OFFSET,
			randf_range(-DROP_SPREAD, DROP_SPREAD),
		)
		await item.start_moving(global_position + new_pos).moved
		item.set_carried(false)
		await get_tree().create_timer(drop_interval).timeout


func _find_nearest(items: Array) -> Honeydew:
	var nearest: Node3D = null
	var nearest_distance: float = INF
	for item: Honeydew in items:
		if item.carried:
			continue
		var distance := global_position.distance_to(item.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = item
	return nearest


func _erase_honeydew(item: Honeydew) -> void:
	var item_id := item.get_instance_id()
	if not nearby_items.keys().has(item_id):
		return
	
	nearby_items.erase(item_id)


func _on_body_entered(item: Node3D) -> void:
	if item is not Honeydew:
		return

	var item_id := item.get_instance_id()
	if nearby_items.keys().has(item_id):
		return
	
	nearby_items[item_id] = item as Honeydew
	if state == GatherState.AWAITING and anthill.space_left() > 0:
		_go_pick_up(item as Honeydew)


func _on_body_exited(item: Node3D) -> void:
	if item is not Honeydew:
		return

	_erase_honeydew(item as Honeydew)
