extends Camera3D
class_name MainCamera

enum CameraState {
	FREE,
	HEADING_TO,
}

const ZOOM_STEP: float = 0.1
const ZOOM_DAMP: float = 5
const ZOOM_VALUE_DEFAULT: float = 0.3
## How many pixels the mouse needs to be away
## from the screen edge to move the camera.
const SCREEN_EDGE_THRESHOLD: float = 10
const HEADING_SPEED: float = 0.75
const WORLD_LIMIT_DISTANCE: float = 150 / 2

const ANIM_MAX_STEP = 10

@export var zoom_in_distance: float = 5
@export var zoom_in_fov: float = 25
@export var zoom_in_angle: float = -0.1 * PI
@export var zoom_in_speed: float = 5
@export var zoom_in_dof_far_distance: float = 7
@export var zoom_in_dof_far_transition: float = 5
@export var zoom_in_dof_near_distance: float = 2
@export var zoom_in_dof_near_transition: float = 1

@export var zoom_out_distance: float = 90
@export var zoom_out_fov: float = 30
@export var zoom_out_angle: float = -0.25 * PI
@export var zoom_out_speed: float = 35
@export var zoom_out_dof_far_distance: float = 100
@export var zoom_out_dof_far_transition: float = 40
@export var zoom_out_dof_near_distance: float = 80
@export var zoom_out_dof_near_transition: float = 20

var target_position: Vector3 = Vector3.ZERO
var mouse_position: Vector2 = Vector2.ZERO
## 0 = zoomed in. 1 = zoomed out.
var zoom_value: float = ZOOM_VALUE_DEFAULT
var zoom_unsmoothed: float = zoom_value
var advance_anim_step: int = 1

var heading_to_position: Vector3 = Vector3.ZERO
var heading_to_zoom: float = 0
var heading_from_position: Vector3 = Vector3.ZERO
var heading_from_zoom: float = 0
var heading_progress: float = 0

var state: CameraState = CameraState.FREE

var window_out_of_focus: bool = false

@onready var attrs: CameraAttributesPractical = attributes
@onready var listener: AudioListener3D = $AudioListener3D


func _ready() -> void:
	assert(attrs != null, "attrs missing!")
	assert(listener != null, "listener missing!")
	target_position = StaticNodesManager.player_anthill.global_position
	listener.make_current()


func _process(delta: float) -> void:
	_handle_heading_to(delta)
	_handle_movement(delta)

	zoom_value = lerpf(zoom_value, zoom_unsmoothed, delta * ZOOM_DAMP)
	
	fov = lerpf(zoom_in_fov, zoom_out_fov, zoom_value)
	global_rotation.x = lerpf(zoom_in_angle, zoom_out_angle, zoom_value)
	var distance: float = lerpf(zoom_in_distance, zoom_out_distance, zoom_value)

	var offset_direction := Vector3.BACK.rotated(Vector3.RIGHT, global_rotation.x)
	var offset := offset_direction * distance
	global_position = target_position + offset
	listener.global_position = target_position + (Vector3.UP * distance)
	listener.global_rotation = global_rotation

	_handle_dof()
	_handle_advance_anim_step()

	DebugManager.marker(target_position, 0.05)
	DebugManager.marker(listener.global_position, 0.05, Color.GREEN)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = (event as InputEventMouseMotion).position
	
	if event is InputEventMouseButton:
		var button_event := event as InputEventMouseButton
		if button_event.pressed:
			if button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_unsmoothed -= ZOOM_STEP
			elif button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_unsmoothed += ZOOM_STEP
			zoom_unsmoothed = clampf(zoom_unsmoothed, 0, 1)

	if event.is_action_pressed("reset_camera"):
		head_to(StaticNodesManager.player_anthill.global_position)


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


func _handle_advance_anim_step() -> void:
	var remapped_unclamped := remap(
			zoom_value,
			ZOOM_VALUE_DEFAULT,
			1,
			0,
			1,
	)
	var clamped := clampf(remapped_unclamped, 0, 1)
	advance_anim_step = roundi(lerpf(1, ANIM_MAX_STEP, clamped))


func _handle_dof() -> void:
	attrs.dof_blur_far_distance = lerpf(
			zoom_in_dof_far_distance,
			zoom_out_dof_far_distance,
			zoom_value,
	)
	attrs.dof_blur_far_transition = lerpf(
			zoom_in_dof_far_transition,
			zoom_out_dof_far_transition,
			zoom_value,
	)
	attrs.dof_blur_near_distance = lerpf(
			zoom_in_dof_near_distance,
			zoom_out_dof_near_distance,
			zoom_value,
	)
	attrs.dof_blur_near_transition = lerpf(
			zoom_in_dof_near_transition,
			zoom_out_dof_near_transition,
			zoom_value,
	)


func _handle_movement(delta: float) -> void:
	if (
			window_out_of_focus
			or state != CameraState.FREE
			or CursorManager.disable_confinement
			or SelectionManager.selecting
	):
		return

	var viewport_size := get_viewport().get_visible_rect().size

	var move_input := Vector2()

	# Horizontal
	if (mouse_position.x <= SCREEN_EDGE_THRESHOLD):
		move_input.x = -1
	elif (mouse_position.x > viewport_size.x - SCREEN_EDGE_THRESHOLD):
		move_input.x = 1
	else:
		move_input.x = 0

	# Vertical
	if (mouse_position.y <= SCREEN_EDGE_THRESHOLD):
		move_input.y = -1
	elif (mouse_position.y > viewport_size.y - SCREEN_EDGE_THRESHOLD):
		move_input.y = 1
	else:
		move_input.y = 0

	var direction := (
			Vector3(move_input.x, 0, move_input.y)
			.rotated(Vector3.UP, global_rotation.y)
	)

	var speed: float = lerpf(zoom_in_speed, zoom_out_speed, zoom_value)
	var velocity := direction * speed
	target_position += velocity * delta
	target_position.x = clampf(target_position.x, -WORLD_LIMIT_DISTANCE, WORLD_LIMIT_DISTANCE)
	target_position.z = clampf(target_position.z, -WORLD_LIMIT_DISTANCE, WORLD_LIMIT_DISTANCE)


func _handle_heading_to(delta: float) -> void:
	if state != CameraState.HEADING_TO:
		return

	if heading_progress >= 1:
		target_position = heading_to_position
		state = CameraState.FREE
	
	heading_progress += HEADING_SPEED * delta
	var eased_progress := ease(heading_progress, -3)
	target_position = heading_from_position.lerp(
			heading_to_position,
			eased_progress
	)
	zoom_unsmoothed = bezier_interpolate(
			heading_from_zoom,
			1,
			1,
			heading_to_zoom,
			eased_progress,
	)
	zoom_value = zoom_unsmoothed
