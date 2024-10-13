extends Node
## Handles fullscreen toggling.

var _is_fullscreen: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		_toggle_fullscreen()


func _toggle_fullscreen() -> void:
	_is_fullscreen = not _is_fullscreen
	if _is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
