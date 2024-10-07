extends Interactable
class_name Unit

const MOVE_SPEED: float = 3
const TURN_SPEED: float = 10

var max_wander_distance: float = 5
var min_wander_interval: float = 0.25
var max_wander_interval: float = 5

var is_on_screen: bool = false
var wandering_timer: float = 0
var wandering_center: Vector3 = Vector3.ZERO
var spawn_pos: Vector3

var locomotion_value: float = 0
var showing_info: bool = false
var advance_anim_delta_accum: float = 0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var ui_origin: Node3D = $UiOrigin
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var anim_advance_indicator: VisualInstance3D = $AnimAdvanceIndicator
@onready var visibility_notifier: VisibleOnScreenNotifier3D = (
		$VisibleOnScreenNotifier3D
)
@onready var main_camera: MainCamera = $/root/World/MainCamera
@onready var audio_player: AudioStreamPlayerPolyphonic = (
		$AudioStreamPlayerPolyphonic
)


func _ready() -> void:
	assert(nav_agent != null, "nav_agent missing!")
	assert(animation_tree != null, "animation_tree missing!")
	assert(visibility_notifier != null, "visibility_notifier missing!")
	assert(ui_origin != null, "ui_origin missing!")
	assert(main_camera != null, "main_camera missing!")
	assert(anim_advance_indicator != null, "anim_advance_indicator missing!")
	assert(audio_player != null, "audio_player missing!")
	super._ready()

	anim_advance_indicator.visible = false
	if spawn_pos != null and spawn_pos != Vector3.ZERO:
		global_position = spawn_pos

	wandering_center = global_position
	nav_agent.max_speed = MOVE_SPEED
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
	_animate(delta)


func _physics_process(_delta: float) -> void:
	_navigate()


func toggle_info(on: bool) -> void:
	showing_info = on


func _click() -> void:
	UiManager.unit_info.open(self)
	toggle_info(true)


func _navigate() -> void:
	if nav_agent.is_navigation_finished():
		velocity = Vector3.ZERO
		return
		
	var next_pos := nav_agent.get_next_path_position()

	var direction := global_position.direction_to(next_pos)
	var new_velocity := direction * MOVE_SPEED
	nav_agent.set_velocity(new_velocity)


func _animate(delta: float) -> void:
	if not is_on_screen:
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

	locomotion_value = move_toward(
			locomotion_value,
			velocity.length() / MOVE_SPEED,
			delta * 8
	)
	animation_tree.set("parameters/locomotion/blend_position", locomotion_value)

	advance_anim_delta_accum += delta

	var advance_anim_step := maxi(
		main_camera.advance_anim_step,
		SelectionManager.advance_anim_step
	)
	var frame := Engine.get_frames_drawn()
	var advance := (frame + get_instance_id()) % advance_anim_step == 0
	anim_advance_indicator.visible = advance and DebugManager.enabled
	if advance:
		animation_tree.advance(advance_anim_delta_accum)
		advance_anim_delta_accum = 0
	

func _wander(delta: float) -> void:
	wandering_timer -= delta
	if wandering_timer <= 0:
		var new_pos_offset := Vector3(
				randf_range(-max_wander_distance, max_wander_distance),
				0,
				randf_range(-max_wander_distance, max_wander_distance),
		)
		var new_pos := wandering_center + new_pos_offset
		nav_agent.set_target_position(new_pos)
		wandering_timer = randf_range(-min_wander_interval, max_wander_interval)


func _on_nav_agent_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	move_and_slide()


func _on_visibility_notifier_screen_entered() -> void:
	is_on_screen = true


func _on_visibility_notifier_screen_exited() -> void:
	is_on_screen = false
