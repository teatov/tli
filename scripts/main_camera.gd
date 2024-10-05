extends Camera3D

const ZOOM_SPEED: float = 0.25
## How many pixels the mouse needs to be away
## from the screen edge to move the camera.
const EDGE_THRESHOLD: float = 10

@export var zoom_in_distance: float = 5
@export var zoom_in_fov: float = 25
@export var zoom_in_angle: float = -0.1 * PI
@export var zoom_in_speed: float = 5

@export var zoom_out_distance: float = 90
@export var zoom_out_fov: float = 20
@export var zoom_out_angle: float = -0.25 * PI
@export var zoom_out_speed: float = 30

var target_position: Vector3 = Vector3(0, 0, 0)
var mouse_position: Vector2 = Vector2()
## 0 = zoomed in. 1 = zoomed out.
var zoom_value: float = 0.25

func _process(delta: float) -> void:
	handle_movement(delta)

	fov = lerp(zoom_in_fov, zoom_out_fov, zoom_value)
	rotation.x = lerp(zoom_in_angle, zoom_out_angle, zoom_value)
	var distance: float = lerp(zoom_in_distance, zoom_out_distance, zoom_value)

	var offset_direction := Vector3.BACK.rotated(Vector3.RIGHT, rotation.x)
	var offset := offset_direction * distance
	position = target_position + offset

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = (event as InputEventMouseMotion).position
	
	if event is InputEventMouseButton:
		var button_event := event as InputEventMouseButton
		if button_event.pressed:
			if button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_value -= ZOOM_SPEED
			elif button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_value += ZOOM_SPEED
			zoom_value = clamp(zoom_value, 0, 1)

func handle_movement(delta: float) -> void:
	var viewport_size := get_viewport().get_visible_rect().size

	var move_input := Vector2()

	# Horizontal
	if (mouse_position.x <= EDGE_THRESHOLD):
		move_input.x = -1
	elif (mouse_position.x >= viewport_size.x - EDGE_THRESHOLD - 1):
		move_input.x = 1
	else:
		move_input.x = 0

	# Vertical
	if (mouse_position.y <= EDGE_THRESHOLD):
		move_input.y = -1
	elif (mouse_position.y >= viewport_size.y - EDGE_THRESHOLD - 1):
		move_input.y = 1
	else:
		move_input.y = 0

	var direction := (
			Vector3(move_input.x, 0, move_input.y)
			.rotated(Vector3.UP, rotation.y)
	)

	var speed: float = lerp(zoom_in_speed, zoom_out_speed, zoom_value)
	var velocity := direction * speed
	target_position += velocity * delta
