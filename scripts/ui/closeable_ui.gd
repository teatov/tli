extends Control
class_name CloseableUI

var _is_mouse_over: bool = false


func _ready() -> void:
	visible = false


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventMouseButton and not _is_mouse_over:
		var button_event := event as InputEventMouseButton
		if not button_event.pressed:
			return
		if button_event.button_index == MOUSE_BUTTON_LEFT:
			close()

	if event is InputEventMouseMotion:
		var motion_event := event as InputEventMouseMotion
		_is_mouse_over = (
				Rect2(global_position, size)
				.has_point(motion_event.position)
		)


func close() -> void:
	visible = false
