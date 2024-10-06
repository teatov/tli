extends Control
class_name FollowingUi

const EDGE_MARGIN = 10

var target: Node3D
var is_mouse_over: bool = false

@onready var camera: Camera3D = get_viewport().get_camera_3d()

func _ready() -> void:
	assert(camera != null, "camera missing!")
	visible = false


func _process(_delta: float) -> void:
	if not visible or target == null:
		return

	var pos := camera.unproject_position(target.global_position)
	var corner_1 := Vector2.ONE * EDGE_MARGIN
	var viewport_size := get_viewport().get_visible_rect().size
	var corner_2 := Vector2(
			viewport_size.x - size.x - EDGE_MARGIN,
			viewport_size.y - size.y - EDGE_MARGIN,
	)
	position = (pos - pivot_offset).clamp(corner_1, corner_2)


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventMouseButton and not is_mouse_over:
		var button_event := event as InputEventMouseButton
		if not button_event.pressed:
			return
		if (
				button_event.button_index == MOUSE_BUTTON_RIGHT
				or button_event.button_index == MOUSE_BUTTON_LEFT
		):
			close()

	if event is InputEventMouseMotion:
		var motion_event := event as InputEventMouseMotion
		is_mouse_over = (
				Rect2(global_position, size)
				.has_point(motion_event.position)
		)


func set_target(to: Node3D) -> void:
	visible = true
	target = to


func close() -> void:
	visible = false
	target = null
