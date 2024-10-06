extends Unit
class_name ControlledUnit

signal moving_started
signal moving_ended

var anthill: Anthill
var spawn_pos: Vector3

var hovered_rect: bool = false
var selected: bool = false
var moving_to_target: bool = false
var ground_plane: Plane = Plane(Vector3.UP, 0)

@onready var camera: Camera3D = get_viewport().get_camera_3d()
@onready var selection_sprite: Sprite3D = $SelectionSprite


func _init() -> void:
	max_wander_distance = 2
	min_wander_interval = 0.5
	max_wander_interval = 30


func _ready() -> void:
	assert(camera != null, "camera missing!")
	assert(selection_sprite != null, "selection_sprite missing!")

	set_selected(false)
	if spawn_pos != null and spawn_pos != Vector3.ZERO:
		global_position = spawn_pos
	super._ready()


func _process(delta: float) -> void:
	super._process(delta)
	selection_sprite.visible = selected
	hover_sprite.visible = hovered or hovered_rect


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if moving_to_target and nav_agent.is_navigation_finished():
		moving_to_target = false
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
				moving_to_target = true
				moving_started.emit()
				_set_target_click(button_event.position)


func initialize(from: Anthill, pos: Vector3) -> ControlledUnit:
	anthill = from
	spawn_pos = pos
	return self


func set_hovered_rect(on: bool) -> void:
	hovered_rect = on


static func get_cost() -> int:
	return 5


func set_selected(on: bool) -> void:
	selected = on


func _interact(with: Interactable) -> void:
	print(self, ' interacting with ', with)


func _set_target_click(mouse_pos: Vector2) -> void:
	var click_pos := _click_raycast(mouse_pos)
	if click_pos == null:
		return
		
	nav_agent.set_target_position(click_pos)


func _click_raycast(mouse_pos: Vector2) -> Vector3:
	var from := camera.global_position
	var to := camera.project_ray_normal(mouse_pos)
	return ground_plane.intersects_ray(from, to)
