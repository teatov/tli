extends Panel
class_name PauseMenu

@onready var cancel_button: BaseButton = $Panel/CancelButton
@onready var quit_button: BaseButton = $Panel/QuitButton


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


func _close() -> void:
	visible = false
	get_tree().paused = false


func _on_cancel_button_pressed() -> void:
	print('cancel')
	_close()


func _on_quit_button_pressed() -> void:
	print('quit')
	get_tree().quit()
