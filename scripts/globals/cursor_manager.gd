extends Node

const CURSOR_HOTSPOT = Vector2(32, 32)

var cursor_normal := load("res://assets/textures/gui/cursor.png")
var cursor_click := load("res://assets/textures/gui/cursor_click.png")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if (event as InputEventMouseButton).pressed:
			set_cursor(cursor_click)
		else:
			set_cursor(cursor_normal)

func set_cursor(image: Resource) -> void:
	Input.set_custom_mouse_cursor(image, Input.CURSOR_ARROW, CURSOR_HOTSPOT)
