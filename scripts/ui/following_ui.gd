extends Control
class_name FollowingUi

var target: Node3D
var is_mouse_over: bool = false

@onready var camera: Camera3D = get_viewport().get_camera_3d()
@onready var panel: Panel = $Panel

func _ready() -> void:
	assert(camera != null, "camera missing!")
	assert(panel != null, "panel missing!")
	visible = false


func _process(_delta: float) -> void:
	if not visible or target == null:
		return

	var pos := camera.unproject_position(target.global_position)
	position = pos


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
				Rect2(panel.global_position, panel.size)
				.has_point(motion_event.position)
		)


func set_target(to: Node3D) -> void:
	visible = true
	target = to


func close() -> void:
	visible = false
	target = null
