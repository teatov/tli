extends Camera3D

enum CameraState {
	FREE,
	HEADING_TO,
}

const ZOOM_SPEED: float = 0.1
const ZOOM_DAMP: float = 5
const ZOOM_VALUE_DEFAULT: float = 0.3
## How many pixels the mouse needs to be away
## from the screen edge to move the camera.
const EDGE_THRESHOLD: float = 10
const HEADING_SPEED: float = 0.75

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

var heading_to_position: Vector3 = Vector3.ZERO
var heading_to_zoom: float = 0
var heading_from_position: Vector3 = Vector3.ZERO
var heading_from_zoom: float = 0
var heading_progress: float = 0

var state: CameraState = CameraState.FREE

var window_out_of_focus: bool = false


func _process(delta: float) -> void:
	_handle_heading_to(delta)
	zoom_value = lerp(zoom_value, zoom_raw, delta * ZOOM_DAMP)

	_handle_movement(delta)

	fov = lerp(zoom_in_fov, zoom_out_fov, zoom_value)
	rotation.x = lerp(zoom_in_angle, zoom_out_angle, zoom_value)
	var distance: float = lerp(zoom_in_distance, zoom_out_distance, zoom_value)

	var offset_direction := Vector3.BACK.rotated(Vector3.RIGHT, rotation.x)
	var offset := offset_direction * distance
	global_position = target_position + offset

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
		head_to(Vector3.ZERO)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		window_out_of_focus = false
	elif what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		window_out_of_focus = true


## Start gradually moving camera towards a position
func head_to(to: Vector3, zoom: float = ZOOM_VALUE_DEFAULT) -> void:
	heading_to_position = to
	heading_from_position = target_position
	heading_progress = 0
	heading_from_zoom = zoom_value
	heading_to_zoom = zoom
	state = CameraState.HEADING_TO


func _handle_movement(delta: float) -> void:
	if window_out_of_focus or state != CameraState.FREE:
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


func _handle_heading_to(delta: float) -> void:
	if state != CameraState.HEADING_TO:
		return

	if heading_progress >= 1:
		target_position = heading_to_position
		state = CameraState.FREE
	
	heading_progress += HEADING_SPEED * delta
	var eased_progress := ease(heading_progress, -3)
	target_position = lerp(
			heading_from_position, 
			heading_to_position, 
			eased_progress,
	)
	zoom_raw = quadratic_bezier(
			heading_from_zoom, 
			1, 
			heading_to_zoom, 
			eased_progress,
	)
	zoom_value = zoom_raw

	
func quadratic_bezier(
		p0: float,
		p1: float,
		p2: float,
		t: float,
) -> float:
	var q0: float = lerp(p0, p1, t)
	var q1: float = lerp(p1, p2, t)
	var r: float = lerp(q0, q1, t)
	return r
