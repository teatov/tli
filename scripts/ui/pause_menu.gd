extends Panel
class_name PauseMenu

const OPEN_TWEEN_DURATION: float = 0.5
const CLOSE_TWEEN_DURATION: float = 0.25

var _tween: Tween

@onready var cancel_button: BaseButton = $Panel/CancelButton
@onready var quit_button: BaseButton = $Panel/QuitButton
@onready var panel: Control = $Panel
@onready var controls_info: Control = $ControlsInfo
@onready var _controls_info_pos: Vector2 = controls_info.position


func _ready() -> void:
	assert(cancel_button != null, "cancel_button missing!")
	assert(quit_button != null, "quit_button missing!")
	cancel_button.pressed.connect(_on_cancel_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		if visible:
			_close()
		else:
			visible = true
			get_tree().paused = true
			_open_animation()
			

func _close() -> void:
	get_tree().paused = false
	await _close_animation()
	visible = false


func _on_cancel_button_pressed() -> void:
	print("cancel")
	_close()


func _on_quit_button_pressed() -> void:
	print("quit")
	get_tree().quit()


func _open_animation() -> void:
	if _tween:
		_tween.stop()
	panel.scale = Vector2.ZERO
	controls_info.position = Vector2(_controls_info_pos.x, 1080)
	_tween = create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	(
			_tween
			.tween_property(controls_info, "position", _controls_info_pos, OPEN_TWEEN_DURATION)
			.set_ease(Tween.EASE_OUT)
			.set_trans(Tween.TRANS_ELASTIC)
	)
	await (
			_tween
			.parallel()
			.tween_property(panel, "scale", Vector2.ONE, OPEN_TWEEN_DURATION)
			.set_ease(Tween.EASE_OUT)
			.set_trans(Tween.TRANS_ELASTIC)
			.finished
	)

func _close_animation() -> void:
	if _tween:
		_tween.stop()
	panel.scale = Vector2.ONE
	controls_info.position = _controls_info_pos
	_tween = create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	(
			_tween
			.tween_property(
					controls_info,
					"position",
					Vector2(_controls_info_pos.x, 1080),
					CLOSE_TWEEN_DURATION,
			)
			.set_ease(Tween.EASE_IN)
			.set_trans(Tween.TRANS_BACK)
	)
	await (
			_tween
			.parallel()
			.tween_property(panel, "scale", Vector2.ZERO, CLOSE_TWEEN_DURATION)
			.set_ease(Tween.EASE_IN)
			.set_trans(Tween.TRANS_BACK)
			.finished
	)
