extends Control
class_name ShowOnHover

const OPEN_TWEEN_DURATION: float = 0.5
const CLOSE_TWEEN_DURATION: float = 0.25

@export var hovered_control: Control

var _tween: Tween

func _ready() -> void:
	assert(hovered_control != null, "hovered_control missing!")
	scale = Vector2.ZERO
	hovered_control.mouse_entered.connect(_on_mouse_entered)
	hovered_control.mouse_exited.connect(_on_mouse_exited)


func _open_animation() -> void:
	await _animate(
			Vector2.ZERO,
			Vector2.ONE,
			OPEN_TWEEN_DURATION,
			Tween.EASE_OUT,
			Tween.TRANS_ELASTIC,
	)


func _close_animation() -> void:
	await _animate(
			Vector2.ONE,
			Vector2.ZERO,
			CLOSE_TWEEN_DURATION,
			Tween.EASE_IN,
			Tween.TRANS_BACK,
	)


func _animate(
		from_scale: Vector2,
		to_scale: Vector2,
		duration: float,
		ease_type: Tween.EaseType,
		trans_type: Tween.TransitionType,
) -> void:
	if _tween:
		_tween.kill()
	scale = from_scale
	_tween = create_tween()
	await (
			_tween
			.tween_property(self, "scale", to_scale, duration)
			.set_ease(ease_type)
			.set_trans(trans_type)
			.finished
	)


func _on_mouse_entered() -> void:
	_open_animation()


func _on_mouse_exited() -> void:
	_close_animation()