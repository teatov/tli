extends Unit
class_name ControlledUnit

signal moving_started
signal moving_ended

var anthill: Anthill

var hovered_rect: bool = false
var selected: bool = false
var is_relocating: bool = false
var ground_plane: Plane = Plane(Vector3.UP, 0)

@onready var camera: Camera3D = get_viewport().get_camera_3d()
@onready var selection_indicator: VisualInstance3D = $SelectionIndicator


static func get_cost() -> int:
	return 5


func _init() -> void:
	max_wander_distance = 2
	min_wander_interval = 0.5
	max_wander_interval = 10


func _ready() -> void:
	assert(camera != null, "camera missing!")
	assert(selection_indicator != null, "selection_indicator missing!")
	nav_agent.navigation_finished.connect(_on_nav_agent_navigation_finished)
	super._ready()


func _process(delta: float) -> void:
	super._process(delta)
	selection_indicator.visible = selected
	hover_indicator.visible = hovered or hovered_rect


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if is_relocating and nav_agent.is_navigation_finished():
		is_relocating = false
		moving_ended.emit()


func _input(event: InputEvent) -> void:
	super._input(event)
	if not is_on_screen:
		return

	if event is InputEventMouseButton and selected:
		var button_event := event as InputEventMouseButton
		if (
				button_event.button_index == MOUSE_BUTTON_RIGHT
				and button_event.pressed
		):
			if HoveringManager.hovered_node is Interactable:
				_interact(HoveringManager.hovered_node as Interactable)
			else:
				moving_started.emit()
				_set_target_click(button_event.position)


func initialize(from: Anthill, pos: Vector3) -> ControlledUnit:
	anthill = from
	spawn_pos = pos
	return self


func set_hovered_rect(on: bool) -> void:
	hovered_rect = on


func set_selected(on: bool) -> void:
	selected = on


func navigate(to: Vector3, relocating: bool = false) -> void:
	is_relocating = relocating
	nav_agent.set_target_position(to)


func _interact(with: Interactable) -> void:
	print(self, ' interacting with ', with)


func _set_target_click(mouse_pos: Vector2) -> void:
	var click_pos := _click_raycast(mouse_pos)
	if click_pos == null:
		return
		
	navigate(click_pos, true)


func _click_raycast(mouse_pos: Vector2) -> Vector3:
	var from := camera.global_position
	var to := camera.project_ray_normal(mouse_pos)
	return ground_plane.intersects_ray(from, to)


func _on_nav_agent_navigation_finished() -> void:
	wandering_center = nav_agent.get_final_position()
