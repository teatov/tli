extends TextureButton
class_name AnimatedTextureButton

const TWEEN_DURATION: float = 0.5
const HOVER_SCALE: Vector2 = Vector2(0.8, 1.2)
const PRESS_SCALE: Vector2 = Vector2(1.2, 0.8)

var _tween: Tween

func _ready() -> void:
	button_down.connect(_press_down_animation)
	button_up.connect(_press_up_animation)
	mouse_entered.connect(_hover_over_animation)
	mouse_exited.connect(_hover_off_animation)


func _press_down_animation() -> void:
	_animate(PRESS_SCALE)


func _press_up_animation() -> void:
	if is_hovered():
		_animate(HOVER_SCALE)
	else:
		_animate(Vector2.ONE)


func _hover_over_animation() -> void:
	_animate(HOVER_SCALE)


func _hover_off_animation() -> void:
	_animate(Vector2.ONE)


func _animate(to_scale: Vector2) -> void:
	if _tween:
		_tween.stop()
	_tween = create_tween()
	await (
			_tween
			.tween_property(self, "scale", to_scale, TWEEN_DURATION)
			.set_ease(Tween.EASE_OUT)
			.set_trans(Tween.TRANS_ELASTIC)
			.finished
	)
