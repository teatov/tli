extends Node

const CURSOR_HOTSPOT = Vector2(32, 32)

var cursor_normal := load("res://assets/textures/gui/cursor.png")
var cursor_click := load("res://assets/textures/gui/cursor_click.png")

var disable_confinement: bool = false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var button_event := event as InputEventMouseButton
		if (
				button_event.button_index == MOUSE_BUTTON_LEFT
				or button_event.button_index == MOUSE_BUTTON_RIGHT
		):
			if button_event.pressed:
				_set_cursor(cursor_click)
			else:
				_set_cursor(cursor_normal)

	if event.is_action_pressed("toggle_camera_navigation"):
		disable_confinement = not disable_confinement
		if disable_confinement:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED



func _set_cursor(image: Resource) -> void:
	Input.set_custom_mouse_cursor(image, Input.CURSOR_ARROW, CURSOR_HOTSPOT)
