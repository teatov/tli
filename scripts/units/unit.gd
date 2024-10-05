extends CharacterBody3D
class_name Unit

const MOVE_SPEED: float = 3
const TURN_SPEED: float = 10

var hovered: bool = false
var is_on_screen: bool = false

@onready var hover_sprite: Sprite3D = $HoverSprite
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var visibility_notifier: VisibleOnScreenNotifier3D = (
		$VisibleOnScreenNotifier3D
)


func _ready() -> void:
	assert(hover_sprite != null, "hover_sprite missing!")
	assert(nav_agent != null, "nav_agent missing!")
	assert(animation_player != null, "animation_player missing!")
	assert(visibility_notifier != null, "visibility_notifier missing!")

	set_hovered(false)
	nav_agent.max_speed = MOVE_SPEED
	nav_agent.velocity_computed.connect(_on_nav_agent_velocity_computed)
	set_max_slides(2)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	visibility_notifier.screen_entered.connect(
			_on_visibility_notifier_screen_entered,
	)
	visibility_notifier.screen_exited.connect(
			_on_visibility_notifier_screen_exited,
	)


func _process(delta: float) -> void:
	_animate(delta)


func _physics_process(_delta: float) -> void:
	_navigate()


func set_hovered(on: bool) -> void:
	hovered = on


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
		if velocity.length() > 0.1:
			var velocity_normalized := velocity.normalized()
			global_rotation.y = atan2(
					-velocity_normalized.x, -velocity_normalized.z
			) + PI
		return

	if velocity.length() > 0.1:
		var velocity_normalized := velocity.normalized()
		var angle := atan2(-velocity_normalized.x, -velocity_normalized.z) + PI
		global_rotation.y = rotate_toward(
				global_rotation.y,
				angle,
				TURN_SPEED * delta,
		)
		# look_at(global_position + velocity, Vector3.UP, true)
		animation_player.play('walk')
	else:
		animation_player.play('idle')
	
	hover_sprite.visible = hovered


func _on_nav_agent_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	move_and_slide()


func _on_mouse_entered() -> void:
	set_hovered(true)


func _on_mouse_exited() -> void:
	set_hovered(false)


func _on_visibility_notifier_screen_entered() -> void:
	is_on_screen = true


func _on_visibility_notifier_screen_exited() -> void:
	is_on_screen = false
