extends Interactable
class_name Unit

const TURN_SPEED: float = 10
const LOCOMOTION_CHANGE_SPEED: float = 8

var showing_info: bool = false

var _move_speed: float = 3

var _max_wander_distance: float = 5
var _min_wander_interval: float = 0.25
var _max_wander_interval: float = 10

var _wandering_center: Vector3 = Vector3.ZERO
var _wandering_timer: float = 0

var _spawn_pos: Vector3

var _locomotion_value: float = 0
var _advance_anim_delta_accum: float = 0


@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var ui_origin: Node3D = $UiOrigin
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var anim_advance_indicator: VisualInstance3D = $AnimAdvanceIndicator
@onready var visibility_notifier: VisibleOnScreenNotifier3D = (
		$VisibleOnScreenNotifier3D
)
@onready var audio_player: SoundEffectsPlayer = (
		$SoundEffectsPlayer
)
@onready var move_audio_player: AudioStreamPlayer3D = $MoveSoundPlayer;


func _ready() -> void:
	assert(nav_agent != null, "nav_agent missing!")
	assert(animation_tree != null, "animation_tree missing!")
	assert(visibility_notifier != null, "visibility_notifier missing!")
	assert(ui_origin != null, "ui_origin missing!")
	assert(anim_advance_indicator != null, "anim_advance_indicator missing!")
	assert(audio_player != null, "audio_player missing!")
	assert(move_audio_player != null, "move_audio_player missing!")
	super._ready()

	move_audio_player.pitch_scale += randf_range(-0.25, 0.25)

	anim_advance_indicator.visible = false
	if _spawn_pos != null and _spawn_pos != Vector3.ZERO:
		global_position = _spawn_pos
	_wandering_center = global_position

	nav_agent.max_speed = _move_speed
	nav_agent.velocity_computed.connect(_on_nav_agent_velocity_computed)

	set_max_slides(2)

	visibility_notifier.screen_entered.connect(
			_on_visibility_notifier_screen_entered,
	)
	visibility_notifier.screen_exited.connect(
			_on_visibility_notifier_screen_exited,
	)


func _process(delta: float) -> void:
	super._process(delta)
	_handle_animation(delta)
	_handle_move_sound()
	showing_info = UiManager.unit_info.unit == self


func _physics_process(_delta: float) -> void:
	_handle_navigation()


func _click() -> void:
	UiManager.unit_info.open(self)


func _handle_navigation() -> void:
	if nav_agent.is_navigation_finished():
		velocity = Vector3.ZERO
		return
		
	var next_pos := nav_agent.get_next_path_position()

	var direction := global_position.direction_to(next_pos)
	var new_velocity := direction * _move_speed
	nav_agent.set_velocity(new_velocity)

	if visibility_notifier.is_on_screen():
		DebugManager.vector("nav" + str(get_instance_id()), global_position, next_pos, Color.BLUE)


func _handle_animation(delta: float) -> void:
	if not visibility_notifier.is_on_screen():
		return

	if velocity.length() > 0.01:
		var velocity_normalized := velocity.normalized()
		var angle := atan2(-velocity_normalized.x, -velocity_normalized.z) + PI
		global_rotation.y = rotate_toward(
				global_rotation.y,
				angle,
				TURN_SPEED * delta,
		)
		# look_at(global_position + velocity, Vector3.UP, true)

	_locomotion_value = move_toward(
			_locomotion_value,
			velocity.length() / _move_speed,
			delta * LOCOMOTION_CHANGE_SPEED
	)
	animation_tree["parameters/locomotion_blend/blend_amount"] = _locomotion_value

	_advance_anim_delta_accum += delta

	var advance_anim_step := maxi(
		StaticNodesManager.main_camera.advance_anim_step,
		SelectionManager.advance_anim_step
	)
	var frame := Engine.get_frames_drawn()
	var advance := (frame + get_instance_id()) % advance_anim_step == 0

	if advance:
		animation_tree.advance(_advance_anim_delta_accum)
		_advance_anim_delta_accum = 0
		
	anim_advance_indicator.visible = advance and DebugManager.enabled
	

func _handle_move_sound() -> void:
	if move_audio_player.stream == null:
		return

	if move_audio_player.playing and velocity.length() < _move_speed / 2:
		move_audio_player.stop()
	if not move_audio_player.playing and velocity.length() >= _move_speed / 2:
		move_audio_player.play(randf() * move_audio_player.stream.get_length())


func _wander(delta: float) -> void:
	_wandering_timer -= delta
	if _wandering_timer <= 0:
		var new_pos_offset := Vector3(
				randf_range(-_max_wander_distance, _max_wander_distance),
				0,
				randf_range(-_max_wander_distance, _max_wander_distance),
		)
		var new_pos := _wandering_center + new_pos_offset
		nav_agent.set_target_position(new_pos)
		_wandering_timer = randf_range(-_min_wander_interval, _max_wander_interval)


func _on_nav_agent_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	move_and_slide()


func _on_visibility_notifier_screen_entered() -> void:
	SelectionManager.add_unit_to_visible(self)


func _on_visibility_notifier_screen_exited() -> void:
	SelectionManager.remove_unit_from_visible(self)
