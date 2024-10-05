extends Unit
class_name ControlledUnit

var selected: bool = false
var ground_plane: Plane = Plane(Vector3.UP, 0)

@onready var camera: Camera3D = get_viewport().get_camera_3d()
@onready var selection_sprite: Sprite3D = $SelectionSprite


func _ready() -> void:
	set_selected(false)
	super._ready()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and selected:
		var button_event := event as InputEventMouseButton
		if (
				button_event.button_index == MOUSE_BUTTON_RIGHT
				and button_event.pressed
		):
			_set_target_click(button_event.position)


func set_selected(on: bool) -> void:
	selected = on


func _set_target_click(mouse_pos: Vector2) -> void:
	var click_position := _click_raycast(mouse_pos)
	if click_position == null:
		return
		
	nav_agent.set_target_position(click_position)


func _click_raycast(mouse_pos: Vector2) -> Vector3:
	var from := camera.global_position
	var to := camera.project_ray_normal(mouse_pos)
	return ground_plane.intersects_ray(from, to)


func _animate(delta: float) -> void:
	super._animate(delta)
	selection_sprite.visible = selected
