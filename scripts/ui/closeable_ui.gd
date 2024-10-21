extends Control
class_name CloseableUI

const OPEN_TWEEN_DURATION: float = 0.5
const CLOSE_TWEEN_DURATION: float = 0.25

var _is_mouse_over: bool = false
var _tween: Tween


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
	await _close_animation()
	visible = false


func _open_animation() -> void:
	if _tween:
		_tween.stop()
	scale = Vector2.ZERO
	_tween = create_tween()
	await (
			_tween
			.tween_property(self, "scale", Vector2.ONE, OPEN_TWEEN_DURATION)
			.set_ease(Tween.EASE_OUT)
			.set_trans(Tween.TRANS_ELASTIC)
			.finished
	)

func _close_animation() -> void:
	if _tween:
		_tween.stop()
	scale = Vector2.ONE
	_tween = create_tween()
	await (
			_tween
			.tween_property(self, "scale", Vector2.ZERO, CLOSE_TWEEN_DURATION)
			.set_ease(Tween.EASE_IN)
			.set_trans(Tween.TRANS_BACK)
			.finished
	)
