extends Camera3D

const ZOOM_SPEED: float = 0.1
const ZOOM_DAMP: float = 5
const ZOOM_VALUE_DEFAULT: float = 0.3
## How many pixels the mouse needs to be away
## from the screen edge to move the camera.
const EDGE_THRESHOLD: float = 10

@export var zoom_in_distance: float = 5
@export var zoom_in_fov: float = 25
@export var zoom_in_angle: float = -0.1 * PI
@export var zoom_in_speed: float = 5

@export var zoom_out_distance: float = 90
@export var zoom_out_fov: float = 30
@export var zoom_out_angle: float = -0.25 * PI
@export var zoom_out_speed: float = 35

var target_position: Vector3 = Vector3.ZERO
var mouse_position: Vector2 = Vector2()
## 0 = zoomed in. 1 = zoomed out.
var zoom_value: float = ZOOM_VALUE_DEFAULT
var zoom_raw: float = zoom_value

var mouse_outside_window: bool = false


func _process(delta: float) -> void:
	zoom_value = lerp(zoom_value, zoom_raw, delta * ZOOM_DAMP)

	_handle_movement(delta)

	fov = lerp(zoom_in_fov, zoom_out_fov, zoom_value)
	rotation.x = lerp(zoom_in_angle, zoom_out_angle, zoom_value)
	var distance: float = lerp(zoom_in_distance, zoom_out_distance, zoom_value)

	var offset_direction := Vector3.BACK.rotated(Vector3.RIGHT, rotation.x)
	var offset := offset_direction * distance
	position = target_position + offset

	DebugDraw.marker(target_position, 0.05)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = (event as InputEventMouseMotion).position
	
	if event is InputEventMouseButton:
		var button_event := event as InputEventMouseButton
		if button_event.pressed:
			if button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_raw -= ZOOM_SPEED
			elif button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_raw += ZOOM_SPEED
			zoom_raw = clamp(zoom_raw, 0, 1)

	if event.is_action_pressed("reset_camera"):
		target_position = Vector3.ZERO
		zoom_raw = ZOOM_VALUE_DEFAULT


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_MOUSE_ENTER:
		mouse_outside_window = false
	elif what == NOTIFICATION_WM_MOUSE_EXIT:
		mouse_outside_window = true


func _handle_movement(delta: float) -> void:
	if mouse_outside_window:
		return

	var viewport_size := get_viewport().get_visible_rect().size

	var move_input := Vector2()

	# Horizontal
	if (mouse_position.x <= EDGE_THRESHOLD):
		move_input.x = -1
	elif (mouse_position.x > viewport_size.x - EDGE_THRESHOLD):
		move_input.x = 1
	else:
		move_input.x = 0

	# Vertical
	if (mouse_position.y <= EDGE_THRESHOLD):
		move_input.y = -1
	elif (mouse_position.y > viewport_size.y - EDGE_THRESHOLD):
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
