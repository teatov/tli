extends Camera3D
class_name MainCamera

enum State {
	FREE,
	HEADING_TO,
}

const ZOOM_STEP: float = 0.1
const ZOOM_DAMP: float = 5
const ZOOM_VALUE_DEFAULT: float = 0.3
## How many pixels close to the screen edge
## the mouse needs to be to move the camera.
const SCREEN_EDGE_THRESHOLD: float = 10
const HEADING_SPEED: float = 0.75
const WORLD_LIMIT_DISTANCE: float = 150 / 2

const ANIM_MAX_STEP = 10

@export var _zoom_in_distance: float = 5
@export var _zoom_in_fov: float = 25
@export var _zoom_in_angle: float = -0.1 * PI
@export var _zoom_in_speed: float = 5
@export var _zoom_in_dof_far_distance: float = 7
@export var _zoom_in_dof_far_transition: float = 5
@export var _zoom_in_dof_near_distance: float = 2
@export var _zoom_in_dof_near_transition: float = 1

@export var _zoom_out_distance: float = 90
@export var _zoom_out_fov: float = 30
@export var _zoom_out_angle: float = -0.25 * PI
@export var _zoom_out_speed: float = 35
@export var _zoom_out_dof_far_distance: float = 100
@export var _zoom_out_dof_far_transition: float = 40
@export var _zoom_out_dof_near_distance: float = 80
@export var _zoom_out_dof_near_transition: float = 20

## 0 = zoomed in. 1 = zoomed out.
var zoom_value: float = ZOOM_VALUE_DEFAULT
var advance_anim_step: int = 1

var _target_position: Vector3 = Vector3.ZERO
var _mouse_position: Vector2 = Vector2.ZERO
var _zoom_unsmoothed: float = zoom_value

var _heading_to_position: Vector3 = Vector3.ZERO
var _heading_to_zoom: float = 0
var _heading_from_position: Vector3 = Vector3.ZERO
var _heading_from_zoom: float = 0
var _heading_progress: float = 0

var _state: State = State.FREE

var _window_out_of_focus: bool = false

@onready var attrs: CameraAttributesPractical = attributes
@onready var listener: AudioListener3D = $AudioListener3D


func _ready() -> void:
	assert(attrs != null, "attrs missing!")
	assert(listener != null, "listener missing!")
	_target_position = StaticNodesManager.player_anthill.global_position
	listener.make_current()


func _process(delta: float) -> void:
	_handle_heading_to(delta)
	_handle_movement(delta)

	zoom_value = lerpf(zoom_value, _zoom_unsmoothed, delta * ZOOM_DAMP)

	_handle_dof()
	_handle_advance_anim_step()
	
	fov = lerpf(_zoom_in_fov, _zoom_out_fov, zoom_value)
	global_rotation.x = lerpf(_zoom_in_angle, _zoom_out_angle, zoom_value)
	var distance: float = lerpf(_zoom_in_distance, _zoom_out_distance, zoom_value)

	var offset_direction := Vector3.BACK.rotated(
			Vector3.RIGHT, 
			global_rotation.x
	)
	var offset := offset_direction * distance
	global_position = _target_position + offset
	listener.global_position = _target_position + (Vector3.UP * distance)
	listener.global_rotation = global_rotation

	DebugManager.marker("mc_target", _target_position, 0.05)
	DebugManager.marker("mc_listener", listener.global_position, 0.05, Color.GREEN)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_position = (event as InputEventMouseMotion).position
	
	if event is InputEventMouseButton:
		var button_event := event as InputEventMouseButton
		if button_event.pressed:
			if button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_zoom_unsmoothed -= ZOOM_STEP
			elif button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_unsmoothed += ZOOM_STEP
			_zoom_unsmoothed = clampf(_zoom_unsmoothed, 0, 1)

	if event.is_action_pressed("reset_camera"):
		head_to(StaticNodesManager.player_anthill.global_position)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		_window_out_of_focus = false
	elif what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_window_out_of_focus = true


## Start gradually moving camera towards a position.
func head_to(to: Vector3, zoom: float = ZOOM_VALUE_DEFAULT) -> void:
	_heading_to_position = to
	_heading_from_position = _target_position
	_heading_progress = 0
	_heading_from_zoom = zoom_value
	_heading_to_zoom = zoom
	_state = State.HEADING_TO


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
			_zoom_in_dof_far_distance,
			_zoom_out_dof_far_distance,
			zoom_value,
	)
	attrs.dof_blur_far_transition = lerpf(
			_zoom_in_dof_far_transition,
			_zoom_out_dof_far_transition,
			zoom_value,
	)
	attrs.dof_blur_near_distance = lerpf(
			_zoom_in_dof_near_distance,
			_zoom_out_dof_near_distance,
			zoom_value,
	)
	attrs.dof_blur_near_transition = lerpf(
			_zoom_in_dof_near_transition,
			_zoom_out_dof_near_transition,
			zoom_value,
	)


func _handle_movement(delta: float) -> void:
	if (
			_window_out_of_focus
			or _state != State.FREE
			or CursorManager.disable_confinement
			or SelectionManager.selecting
	):
		return

	var viewport_size := get_viewport().get_visible_rect().size

	var move_input := Vector2()

	# Horizontal
	if (_mouse_position.x <= SCREEN_EDGE_THRESHOLD):
		move_input.x = -1
	elif (_mouse_position.x > viewport_size.x - SCREEN_EDGE_THRESHOLD):
		move_input.x = 1
	else:
		move_input.x = 0

	# Vertical
	if (_mouse_position.y <= SCREEN_EDGE_THRESHOLD):
		move_input.y = -1
	elif (_mouse_position.y > viewport_size.y - SCREEN_EDGE_THRESHOLD):
		move_input.y = 1
	else:
		move_input.y = 0

	var direction := (
			Vector3(move_input.x, 0, move_input.y)
			.rotated(Vector3.UP, global_rotation.y)
	)

	var speed: float = lerpf(_zoom_in_speed, _zoom_out_speed, zoom_value)
	var velocity := direction * speed
	_target_position += velocity * delta
	_target_position.x = clampf(
			_target_position.x, 
			-WORLD_LIMIT_DISTANCE, 
			WORLD_LIMIT_DISTANCE
	)
	_target_position.z = clampf(
			_target_position.z, 
			-WORLD_LIMIT_DISTANCE, 
			WORLD_LIMIT_DISTANCE
	)


func _handle_heading_to(delta: float) -> void:
	if _state != State.HEADING_TO:
		return

	if _heading_progress >= 1:
		_target_position = _heading_to_position
		_state = State.FREE
	
	_heading_progress += HEADING_SPEED * delta
	var eased_progress := ease(_heading_progress, -3)
	_target_position = _heading_from_position.lerp(
			_heading_to_position,
			eased_progress
	)
	_zoom_unsmoothed = bezier_interpolate(
			_heading_from_zoom,
			1,
			1,
			_heading_to_zoom,
			eased_progress,
	)
	zoom_value = _zoom_unsmoothed
