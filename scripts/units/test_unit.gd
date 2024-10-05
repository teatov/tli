extends CharacterBody3D
class_name TestUnit

var selected: bool = false
var ground_plane: Plane = Plane(Vector3.UP, 0)

@onready var selection_sprite: Sprite3D = $SelectionSprite
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var camera: Camera3D = get_viewport().get_camera_3d()


func _ready() -> void:
	set_selected(false)


func _process(_delta: float) -> void:
	_navigate()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var button_event := event as InputEventMouseButton
		if button_event.pressed:
			_set_target_click(button_event.position)


func set_selected(on: bool) -> void:
	selected = on
	selection_sprite.visible = selected


func _set_target_click(mouse_pos: Vector2) -> void:
	var click_position := _click_raycast(mouse_pos)
	print(click_position)
	if click_position == null:
		return
	
	DebugDraw.marker(click_position)
	nav_agent.set_target_position(click_position)


func _click_raycast(mouse_pos: Vector2) -> Vector3:
	var from := camera.position
	var to := camera.project_ray_normal(mouse_pos)
	return ground_plane.intersects_ray(from, to)


func _navigate() -> void:
	if nav_agent.is_navigation_finished():
		return
	
	var target_pos := nav_agent.get_next_path_position()
	DebugDraw.vector(position, target_pos)
	DebugDraw.marker(nav_agent.get_final_position())
	# position = target_pos
