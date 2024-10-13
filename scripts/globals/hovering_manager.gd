extends Node3D
## Handles mouse hovering over units

var hovered_node: Variant

var _mouse_pos: Vector2 = Vector2.ZERO

@onready var camera: Camera3D = StaticNodesManager.main_camera


func _physics_process(_delta: float) -> void:
	if SelectionManager.selecting:
		return

	var space_state := get_world_3d().direct_space_state
	var from := camera.project_ray_origin(_mouse_pos)
	var to := from + camera.project_ray_normal(_mouse_pos) * (camera.far - 1)
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := space_state.intersect_ray(query)
	if not result:
		hovered_node = null
		return
	hovered_node = result["collider"]


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_pos = (event as InputEventMouseMotion).position
