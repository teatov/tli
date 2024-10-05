extends Camera3D

var mouse_position: Vector2 = Vector2(0, 0)

func _process(delta: float) -> void:
	var viewport_size := get_viewport().get_visible_rect().size

	if (mouse_position.x == 0):
		print('left!')
	if (mouse_position.x == viewport_size.x - 1):
		print('right!')
	if (mouse_position.y == 0):
		print('top!')
	if (mouse_position.y == viewport_size.y - 1):
		print('bottom!')

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = (event as InputEventMouseMotion).position
