extends Area3D
class_name Gathering

signal target_set(pos: Vector3)
signal stop_gathering

const DEFAULT_MAX_CARRYING = 3
const DEFAULT_DROP_INTERVAL = 0.25
const DEFAULT_PICKUP_INTERVAL = 0.5
const DROP_SPREAD: float = 0.1

enum GatherState {
	PICKING_UP,
	DEPOSITING,
	STOP,
}

var nearby_items: Dictionary = {}
var carrying_items: Array[Honeydew] = []
var max_carrying: int = DEFAULT_MAX_CARRYING
var deposit_leftover: int = 0
var state: GatherState = GatherState.STOP
var target: Honeydew
var anthill: Anthill
var drop_interval: float = DEFAULT_DROP_INTERVAL
var pickup_interval: float = DEFAULT_PICKUP_INTERVAL


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	for i in range(carrying_items.size()):
		var item := carrying_items[i]
		item.global_position = get_nth_pile_pos(i)

	if target != null:
		DebugDraw.circle(target.global_position)


func initialize(
		from: Anthill,
		max_carry: int = DEFAULT_MAX_CARRYING,
		drop_interv: float = DEFAULT_DROP_INTERVAL,
		pickup_interv: float = DEFAULT_PICKUP_INTERVAL,
) -> void:
	anthill = from
	max_carrying = max_carry
	drop_interval = drop_interv
	pickup_interval = pickup_interv


func go_gather(item: Honeydew) -> void:
	if anthill.space_left() <= 0:
		return
	if carrying_items.size() >= max_carrying:
		go_deposit()
		return
	target = item
	state = GatherState.PICKING_UP
	target_set.emit(item.global_position)


func go_deposit() -> void:
	state = GatherState.DEPOSITING
	target_set.emit(Vector3.ZERO)


func handle_gathering(stop: bool) -> void:
	if stop:
		state = GatherState.STOP


func on_nav_agent_navigation_finished() -> void:
	if state == GatherState.PICKING_UP and target != null:
		_pick_up()

	if state == GatherState.DEPOSITING:
		_deposit()


func set_leftover(value: int) -> void:
	deposit_leftover = value


func stop_all_gathering() -> void:
	state = GatherState.STOP
	target = null

func get_nth_pile_pos(n: int) -> Vector3:
	return (
			global_position
			+ (Vector3.UP * 0.45)
			+ (Vector3.UP * 0.1 * n)
	)


func _pick_up() -> void:
	if not target.carried:
		carrying_items.append(target)
		target.set_carried(true)
		await target.start_moving(
				get_nth_pile_pos(carrying_items.size() - 1)
		).moved

		await get_tree().create_timer(pickup_interval).timeout
		if carrying_items.size() >= max_carrying:
			go_deposit()
			return

	var nearest := _find_nearest(nearby_items.values())
	if nearest != null:
		go_gather(nearest)
		return

	go_deposit()


func _deposit() -> void:
	await get_tree().create_timer(0.5).timeout
	while carrying_items.size() > 0:
		if state != GatherState.DEPOSITING:
			return

		if anthill.space_left() <= 0:
			print('DROP!')
			_drop_everything()
			stop_all_gathering()
			stop_gathering.emit()
			return

		var item := carrying_items.pop_back() as Honeydew
		await item.start_moving(anthill.global_position).moved
		ItemsManager.erase_honeydew(item)
		_erase_honeydew(item)
		item.queue_free()
		anthill.deposit_honeydew(1)
		await get_tree().create_timer(drop_interval).timeout
	
	state = GatherState.PICKING_UP
	var nearest := _find_nearest(nearby_items.values())
	if nearest != null:
		go_gather(nearest)
		return

	var nearest_global := _find_nearest(ItemsManager.honeydews.values())
	if nearest_global != null:
		go_gather(nearest_global)
		return
	
	stop_all_gathering()
	stop_gathering.emit()


func _drop_everything() -> void:
	while carrying_items.size() > 0:
		var item := carrying_items.pop_back() as Honeydew
		var new_pos := Vector3(
			randf_range(-DROP_SPREAD, DROP_SPREAD),
			Honeydew.HEIGHT_OFFSET,
			randf_range(-DROP_SPREAD, DROP_SPREAD),
		)
		await item.start_moving(global_position + new_pos).moved
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


func _on_body_exited(item: Node3D) -> void:
	if item is not Honeydew:
		return

	_erase_honeydew(item as Honeydew)
