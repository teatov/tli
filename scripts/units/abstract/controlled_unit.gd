extends Unit
class_name ControlledUnit

signal moving_started
signal moving_finished

var anthill: Anthill

var _hovered_rect: bool = false
var _selected: bool = false
var _is_moving: bool = false
var _ground_plane: Plane = Plane(Vector3.UP, 0)

@onready var selection_indicator: VisualInstance3D = $SelectionIndicator
@onready var move_target_indicator: VisualInstance3D = $MoveTarget


static func get_cost() -> int:
	return 5


func _init() -> void:
	_max_wander_distance = 2
	_min_wander_interval = 0.5
	_max_wander_interval = 15


func _ready() -> void:
	assert(selection_indicator != null, "selection_indicator missing!")
	nav_agent.navigation_finished.connect(_on_nav_agent_navigation_finished)
	SelectionManager.deselect.connect(_on_selection_manager_deselect)
	super._ready()


func _process(delta: float) -> void:
	super._process(delta)
	selection_indicator.visible = _selected
	hover_indicator.visible = _hovered or _hovered_rect
	move_target_indicator.visible = _is_moving and (_selected or showing_info)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _is_moving and nav_agent.is_navigation_finished():
		_is_moving = false
		moving_finished.emit()


func _input(event: InputEvent) -> void:
	super._input(event)

	if event is InputEventMouseButton and _selected:
		var button_event := event as InputEventMouseButton
		if (
				button_event.button_index == MOUSE_BUTTON_RIGHT
				and button_event.pressed
		):
			if HoveringManager.hovered_node is Interactable:
				_interact(HoveringManager.hovered_node as Interactable)
			else:
				var click_pos := _click_raycast(button_event.position)
				if click_pos == null:
					return
					
				navigate(click_pos, true)
				moving_started.emit()


func initialize(from: Anthill, pos: Vector3) -> ControlledUnit:
	anthill = from
	_spawn_pos = pos
	return self


func set_hovered_rect(on: bool) -> void:
	_hovered_rect = on


func set_selected(on: bool) -> void:
	_selected = on


func navigate(to: Vector3, moving: bool = false) -> void:
	_is_moving = moving
	nav_agent.set_target_position(to)
	if _is_moving:
		move_target_indicator.global_position = nav_agent.get_final_position()


func _interact(with: Interactable) -> void:
	print(self, " interacting with ", with)


func _click_raycast(mouse_pos: Vector2) -> Vector3:
	var from := StaticNodesManager.main_camera.global_position
	var to := StaticNodesManager.main_camera.project_ray_normal(mouse_pos)
	return _ground_plane.intersects_ray(from, to)


func _on_nav_agent_navigation_finished() -> void:
	_wandering_center = nav_agent.get_final_position()


func _on_selection_manager_deselect() -> void:
	if _selected and not SelectionManager.is_unit_visible(self):
		set_selected(false)
