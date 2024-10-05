extends Node

const MIN_DRAG_DISTANCE: float = 15
const UNIT_SELECT_OFFSET: float = 0.25

var frustrum_polygon: ConvexPolygonShape3D = ConvexPolygonShape3D.new()
var frustrum_polygon_points: PackedVector3Array = [
		Vector3.ZERO,
		Vector3.UP,
		Vector3.RIGHT,
		Vector3.BACK,
		Vector3.ONE,
]

var visible_units: Dictionary = {}

var mouse_pressed: bool = false
var selecting: bool = false
var selection_rect: Rect2 = Rect2()

@onready var camera: Camera3D = get_viewport().get_camera_3d()
@onready var frustrum_area: Area3D = $FrustrumArea
@onready var frustrum_collision_shape: CollisionShape3D = (
		$FrustrumArea/FrustrumCollisionShape
)
@onready var rect_panel: Panel = $SelectionRect


func _ready() -> void:
	frustrum_polygon.points = frustrum_polygon_points
	frustrum_collision_shape.shape = frustrum_polygon
	rect_panel.visible = false
	frustrum_area.body_entered.connect(_on_frustrum_area_unit_entered)
	frustrum_area.body_exited.connect(_on_frustrum_area_unit_exited)


func _process(_delta: float) -> void:
	selecting = (
			mouse_pressed
			and selection_rect.size.length() >= MIN_DRAG_DISTANCE
	)

	_handle_frustrum_shape()
	_handle_selection_box()
	_handle_unit_selection()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var button_event := event as InputEventMouseButton
		if button_event.button_index == MOUSE_BUTTON_LEFT:
			mouse_pressed = button_event.pressed
			if mouse_pressed:
				selection_rect.position = button_event.position
				selection_rect.size = Vector2.ZERO
			elif selecting:
				_set_selection_state(false)
	
	if event is InputEventMouseMotion and mouse_pressed:
		var motion_event := event as InputEventMouseMotion
		selection_rect.size = motion_event.position - selection_rect.position


func _handle_frustrum_shape() -> void:
	var viewport_size := get_viewport().get_visible_rect().size

	var origin := camera.global_position
	var far := camera.far - 1
	var corner_1 := camera.project_position(Vector2.ZERO, far)
	var corner_2 := camera.project_position(Vector2(viewport_size.x, 0), far)
	var corner_3 := camera.project_position(Vector2(0, viewport_size.y), far)
	var corner_4 := camera.project_position(viewport_size, far)

	frustrum_polygon_points[0] = origin
	frustrum_polygon_points[1] = corner_1
	frustrum_polygon_points[2] = corner_2
	frustrum_polygon_points[3] = corner_3
	frustrum_polygon_points[4] = corner_4

	frustrum_polygon.points = frustrum_polygon_points


func _handle_selection_box() -> void:
	rect_panel.visible = selecting
	if not selecting:
		return
	
	var rect_abs := selection_rect.abs()

	rect_panel.position = rect_abs.position
	rect_panel.size = rect_abs.size


func _handle_unit_selection() -> void:
	if not selecting:
		return
	
	_set_selection_state(true)


func _set_selection_state(hover: bool) -> void:
	var rect_abs := selection_rect.abs()

	for unit: Node3D in visible_units.values():
		var point := camera.unproject_position(
				unit.global_position
				+ (Vector3.UP * UNIT_SELECT_OFFSET)
		)
		if unit is TestUnit:
			if hover:
				(unit as TestUnit).set_hovered(rect_abs.has_point(point))
			else:
				(unit as TestUnit).set_selected(rect_abs.has_point(point))
				(unit as TestUnit).set_hovered(false)


func _on_frustrum_area_unit_entered(unit: Node3D) -> void:
	var unit_id := unit.get_instance_id()
	if visible_units.keys().has(unit_id):
		return
	
	visible_units[unit_id] = unit


func _on_frustrum_area_unit_exited(unit: Node3D) -> void:
	var unit_id := unit.get_instance_id()
	if not visible_units.keys().has(unit_id):
		return
	
	visible_units.erase(unit_id)
