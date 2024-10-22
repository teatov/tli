extends Area3D
class_name Gathering

const ANTHILL_DEPOSIT_RADIUS: float = 0.75

enum State {
	WAITING_FOR_NEW_ITEMS,
	WAITING_FOR_MORE_SPACE,
	PICKING_UP,
	DEPOSITING,
	STOP,
}

var state: State = State.STOP

var _unit: ControlledUnit

var _nearby_items: Dictionary = {}
var _carrying_items: Array[Honeydew] = []
var _max_carrying: int = 0

var _target: Honeydew
var _skeleton: Skeleton3D

var _drop_interval: float = 0
var _pickup_interval: float = 0
var _item_bones: Array[int] = []
var _showing_after_set: bool = false

@onready var gathering_center: Vector3 = global_position
@onready var collision_shape: CollisionShape3D = $NearbyItemsSearch
@onready var radius_indicator: VisualInstance3D = (
		$NearbyItemsSearch/GatheringRadius
)
@onready var audio_player: SoundEffectsPlayer = (
		$SoundEffectsPlayer
)


func _ready() -> void:
	assert(collision_shape != null, "collision_shape missing!")
	assert(radius_indicator != null, "radius_indicator missing!")
	assert(audio_player != null, "audio_player missing!")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	for i in range(_carrying_items.size()):
		var item := _carrying_items[i]
		item.global_position = _get_nth_pile_pos(i)
	
	collision_shape.global_position = gathering_center
	collision_shape.global_rotation = Vector3.ZERO

	radius_indicator.visible = (
			(state != State.STOP and _unit.showing_info)
			or _showing_after_set
	)

	if _target != null:
		DebugManager.circle("gather_targ", _target.global_position)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and _showing_after_set:
		var button_event := event as InputEventMouseButton
		if not button_event.pressed:
			return
		if (
				button_event.button_index == MOUSE_BUTTON_LEFT
				or button_event.button_index == MOUSE_BUTTON_RIGHT
		):
			_showing_after_set = false


func initialize(
		unit: ControlledUnit,
		skeleton_3d: Skeleton3D,
		bones: Array[int],
		max_carry: int,
		drop_interv: float,
		pickup_interv: float,
) -> void:
	_unit = unit
	_max_carrying = max_carry
	_drop_interval = drop_interv
	_pickup_interval = pickup_interv
	_skeleton = skeleton_3d
	_item_bones = bones
	_unit.moving_started.connect(_on_unit_moving_started)
	_unit.anthill.buy_ant.connect(_on_anthill_buy_ant)
	_unit.nav_agent.navigation_finished.connect(
			_on_nav_agent_navigation_finished
	)


func start_gathering(item: Honeydew) -> void:
	gathering_center = item.global_position
	_showing_after_set = true
	_go_pick_up(item)


func _go_pick_up(item: Honeydew) -> void:
	if _carrying_items.size() == _max_carrying:
		_go_deposit()
		return
	_target = item
	state = State.PICKING_UP
	_unit.navigate(item.global_position)


func _go_deposit() -> void:
	if _unit.anthill.space_left() == 0:
		state = State.WAITING_FOR_MORE_SPACE
		return
	state = State.DEPOSITING
	var dir := _unit.anthill.global_position.direction_to(global_position)
	_unit.navigate(
			_unit.anthill.global_position
			+ dir
			* ANTHILL_DEPOSIT_RADIUS
	)


func _get_nth_pile_pos(n: int) -> Vector3:
	return _skeleton.to_global(
			_skeleton.get_bone_global_pose(_item_bones[n]).origin,
	)


func _pick_up() -> void:
	if _target == null or _target.carried:
		state = State.WAITING_FOR_NEW_ITEMS
		var nearest_item := _find_nearest(_nearby_items.values())
		if nearest_item != null:
			_go_pick_up(nearest_item)
		elif _carrying_items.size() > 0:
			_go_deposit()
		return

	_carrying_items.append(_target)
	_target.set_carried(true)
	audio_player.play_sound(SoundManager.swoosh())
	await _target.start_tweening(
			_get_nth_pile_pos(_carrying_items.size() - 1)
	).tween_finished
	audio_player.play_sound(SoundManager.pop())
	_unit.animation_tree["parameters/plop_down_oneshot/request"] = (
			AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	)

	await get_tree().create_timer(_pickup_interval).timeout
	
	if state == State.STOP:
		return

	var nearest := _find_nearest(_nearby_items.values())
	if _carrying_items.size() == _max_carrying or nearest == null:
		_go_deposit()
		return

	_go_pick_up(nearest)


func _deposit() -> void:
	while _carrying_items.size() > 0:
		if state != State.DEPOSITING:
			return

		if _unit.anthill.space_left() == 0:
			state = State.WAITING_FOR_MORE_SPACE
			return

		var item := _carrying_items.pop_back() as Honeydew
		_unit.animation_tree["parameters/plop_up_oneshot/request"] = (
				AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		)
		audio_player.play_sound(SoundManager.swoosh())

		await item.start_tweening(
				_unit.anthill.deposit_point.global_position
		).tween_finished

		audio_player.play_sound(SoundManager.tok())
		item.remove_from_spawner()
		_remove_honeydew_from_nearby(item)
		item.queue_free()
		_unit.anthill.deposit_honeydew(1)
		await get_tree().create_timer(_drop_interval).timeout
	
	if state == State.STOP:
		return

	var nearest := _find_nearest(_nearby_items.values())
	if nearest == null:
		state = State.WAITING_FOR_NEW_ITEMS
		_unit.navigate(gathering_center)
		return
	
	_go_pick_up(nearest)
	

func _find_nearest(items: Array) -> Honeydew:
	var nearest: Honeydew = null
	var nearest_distance: float = INF
	for item: Honeydew in items:
		if item.carried:
			continue
		var distance := global_position.distance_squared_to(item.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = item
	return nearest


func _remove_honeydew_from_nearby(item: Honeydew) -> void:
	var item_id := item.get_instance_id()
	if not _nearby_items.keys().has(item_id):
		return
	
	_nearby_items.erase(item_id)


func _on_body_entered(item: Node3D) -> void:
	if item is not Honeydew:
		return

	var item_id := item.get_instance_id()
	if _nearby_items.keys().has(item_id):
		return
	
	_nearby_items[item_id] = item as Honeydew
	if (
			state == State.WAITING_FOR_NEW_ITEMS
			or state == State.WAITING_FOR_MORE_SPACE
	):
		_go_pick_up(item as Honeydew)


func _on_body_exited(item: Node3D) -> void:
	if item is not Honeydew:
		return

	_remove_honeydew_from_nearby(item as Honeydew)


func _on_unit_moving_started() -> void:
	state = State.STOP
	_target = null


func _on_nav_agent_navigation_finished() -> void:
	if state == State.PICKING_UP:
		_pick_up()

	if (
			state == State.DEPOSITING
			# and global_position.distance_to(_unit.anthill.global_position) < 2
	):
		_deposit()


func _on_anthill_buy_ant() -> void:
	if state != State.WAITING_FOR_MORE_SPACE:
		return
	
	var nearest := _find_nearest(_nearby_items.values())
	if (
			_carrying_items.size() == _max_carrying
			or (_carrying_items.size() > 0 and nearest == null)
	):
		_go_deposit()
		return

	if nearest != null:
			_go_pick_up(nearest)
	else:
		state = State.WAITING_FOR_NEW_ITEMS
