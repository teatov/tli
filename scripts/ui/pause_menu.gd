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
	await _animate(
			Vector2.ZERO,
			Vector2(_controls_info_pos.x, 1080),
			Vector2.ONE,
			_controls_info_pos,
			OPEN_TWEEN_DURATION,
			Tween.EASE_OUT,
			Tween.TRANS_ELASTIC,
	)

func _close_animation() -> void:
	await _animate(
			Vector2.ONE,
			_controls_info_pos,
			Vector2.ZERO,
			Vector2(_controls_info_pos.x, 1080),
			CLOSE_TWEEN_DURATION,
			Tween.EASE_IN,
			Tween.TRANS_BACK,
	)


func _animate(
		panel_scale_init: Vector2,
		controls_info_pos_init: Vector2,
		panel_scale_new: Vector2,
		controls_info_pos_new: Vector2,
		duration: float,
		ease_type: Tween.EaseType,
		trans_type: Tween.TransitionType,
) -> void:
	if _tween:
		_tween.kill()
	panel.scale = panel_scale_init
	controls_info.position = controls_info_pos_init
	_tween = create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	(
			_tween
			.tween_property(
					controls_info,
					"position",
					controls_info_pos_new,
					duration,
			)
			.set_ease(ease_type)
			.set_trans(trans_type)
	)
	await (
			_tween
			.parallel()
			.tween_property(panel, "scale", panel_scale_new, duration)
			.set_ease(ease_type)
			.set_trans(trans_type)
			.finished
	)