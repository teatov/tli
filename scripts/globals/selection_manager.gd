extends Node

const MIN_DRAG_DISTANCE: float = 15
const UNIT_SELECT_OFFSET: float = 0.25

const ANIM_MAX_STEP = 30
const MIN_VISIBLE_UNITS = 25
const MAX_VISIBLE_UNITS = 120

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
var advance_anim_step: int = 1

var rect_style := preload("res://resources/styles/selection_rect.tres")

@onready var camera: Camera3D = StaticNodesManager.main_camera
@onready var frustrum_area: Area3D = Area3D.new()
@onready var frustrum_collision_shape: CollisionShape3D = CollisionShape3D.new()
@onready var rect_panel: Panel = Panel.new()


func _ready() -> void:
	frustrum_polygon.points = frustrum_polygon_points
	frustrum_collision_shape.shape = frustrum_polygon
	rect_panel.visible = false
	frustrum_area.body_entered.connect(_on_frustrum_area_body_entered)
	frustrum_area.body_exited.connect(_on_frustrum_area_body_exited)
	frustrum_area.input_ray_pickable = false
	frustrum_area.set_collision_mask_value(1, false)
	frustrum_area.set_collision_mask_value(2, true)
	rect_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect_panel.add_theme_stylebox_override("panel", rect_style)
	add_child(rect_panel)
	add_child(frustrum_area)
	frustrum_area.add_child(frustrum_collision_shape)


func _process(_delta: float) -> void:
	selecting = (
			mouse_pressed
			and selection_rect.size.length() >= MIN_DRAG_DISTANCE
	)

	_handle_frustrum_shape()
	_handle_selection_box()
	_handle_unit_selection()
	_handle_advance_anim_step()


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
	
	if event is InputEventMouseMotion:
		if mouse_pressed:
			var mouse_pos := (event as InputEventMouseMotion).position
			selection_rect.size = mouse_pos - selection_rect.position
		

func _handle_advance_anim_step() -> void:
	var remapped_unclamped := remap(
			visible_units.size(),
			MIN_VISIBLE_UNITS,
			MAX_VISIBLE_UNITS,
			0,
			1,
	)
	var clamped := clampf(remapped_unclamped, 0, 1)
	advance_anim_step = roundi(lerpf(1, ANIM_MAX_STEP, clamped))


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

	for unit: Unit in visible_units.values():
		if unit is not ControlledUnit:
			continue
		var controlled_unit := unit as ControlledUnit
		var point := camera.unproject_position(
				unit.global_position
				+ (Vector3.UP * UNIT_SELECT_OFFSET)
		)
		if hover:
			controlled_unit.set_hovered_rect(rect_abs.has_point(point))
		else:
			controlled_unit.set_selected(rect_abs.has_point(point))
			controlled_unit.set_hovered_rect(false)


func _on_frustrum_area_body_entered(unit: Node3D) -> void:
	if unit is not Unit:
		return

	var unit_id := unit.get_instance_id()
	if visible_units.keys().has(unit_id):
		return
	
	visible_units[unit_id] = unit as Unit


func _on_frustrum_area_body_exited(unit: Node3D) -> void:
	var unit_id := unit.get_instance_id()
	if not visible_units.keys().has(unit_id):
		return
	
	visible_units.erase(unit_id)
