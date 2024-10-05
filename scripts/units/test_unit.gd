extends CharacterBody3D
class_name TestUnit

const MOVE_SPEED: float = 3
const TURN_SPEED: float = 10

var selected: bool = false
var ground_plane: Plane = Plane(Vector3.UP, 0)

@onready var camera: Camera3D = get_viewport().get_camera_3d()
@onready var selection_sprite: Sprite3D = $SelectionSprite
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	set_selected(false)
	nav_agent.max_speed = MOVE_SPEED
	nav_agent.velocity_computed.connect(_on_nav_agent_velocity_computed)
	set_max_slides(2)


func _process(delta: float) -> void:
	_animate(delta)


func _physics_process(_delta: float) -> void:
	_navigate()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and selected:
		var button_event := event as InputEventMouseButton
		if (
				button_event.button_index == MOUSE_BUTTON_RIGHT
				and button_event.pressed
		):
			_set_target_click(button_event.position)


func set_selected(on: bool) -> void:
	selected = on
	selection_sprite.visible = selected


func _set_target_click(mouse_pos: Vector2) -> void:
	var click_position := _click_raycast(mouse_pos)
	if click_position == null:
		return
		
	nav_agent.set_target_position(click_position)


func _click_raycast(mouse_pos: Vector2) -> Vector3:
	var from := camera.global_position
	var to := camera.project_ray_normal(mouse_pos)
	return ground_plane.intersects_ray(from, to)


func _navigate() -> void:
	if nav_agent.is_navigation_finished():
		velocity = Vector3.ZERO
		return
		
	var next_pos := nav_agent.get_next_path_position()

	var direction := global_position.direction_to(next_pos)
	var new_velocity := direction * MOVE_SPEED
	nav_agent.set_velocity(new_velocity)


func _animate(delta: float) -> void:
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


func _on_nav_agent_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	move_and_slide()
