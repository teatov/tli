extends Node
## Handles selection of units.

const MIN_DRAG_DISTANCE: float = 15
const UNIT_SELECT_OFFSET: float = 0.25

const ANIM_MAX_STEP = 30
const MIN_VISIBLE_UNITS = 25
const MAX_VISIBLE_UNITS = 120

var selecting: bool = false
var advance_anim_step: int = 1

var _visible_units: Dictionary = {}

var _mouse_pressed: bool = false
var _selection_rect: Rect2 = Rect2()

var _rect_style := preload("res://resources/styles/selection_rect.tres")

@onready var camera: Camera3D = StaticNodesManager.main_camera
@onready var rect_panel: Panel = Panel.new()


func _ready() -> void:
	rect_panel.visible = false
	rect_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect_panel.add_theme_stylebox_override("panel", _rect_style)
	add_child(rect_panel)


func _process(_delta: float) -> void:
	selecting = (
			_mouse_pressed
			and _selection_rect.size.length() >= MIN_DRAG_DISTANCE
	)

	_handle_selection_box()
	_handle_unit_selection()
	_handle_advance_anim_step()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var button_event := event as InputEventMouseButton
		if button_event.button_index == MOUSE_BUTTON_LEFT:
			_mouse_pressed = button_event.pressed
			if _mouse_pressed:
				_selection_rect.position = button_event.position
				_selection_rect.size = Vector2.ZERO
			elif selecting:
				_set_selection_state(false)
	
	if event is InputEventMouseMotion:
		if _mouse_pressed:
			var mouse_pos := (event as InputEventMouseMotion).position
			_selection_rect.size = mouse_pos - _selection_rect.position
		

func add_unit_to_visible(unit: Unit) -> void:
	var unit_id := unit.get_instance_id()
	if _visible_units.keys().has(unit_id):
		return
	
	_visible_units[unit_id] = unit as Unit


func remove_unit_from_visible(unit: Unit) -> void:
	var unit_id := unit.get_instance_id()
	if not _visible_units.keys().has(unit_id):
		return
	
	_visible_units.erase(unit_id)


func _handle_advance_anim_step() -> void:
	var remapped_unclamped := remap(
			_visible_units.size(),
			MIN_VISIBLE_UNITS,
			MAX_VISIBLE_UNITS,
			0,
			1,
	)
	var clamped := clampf(remapped_unclamped, 0, 1)
	advance_anim_step = roundi(lerpf(1, ANIM_MAX_STEP, clamped))


func _handle_selection_box() -> void:
	rect_panel.visible = selecting
	if not selecting:
		return
	
	var rect_abs := _selection_rect.abs()

	rect_panel.position = rect_abs.position
	rect_panel.size = rect_abs.size


func _handle_unit_selection() -> void:
	if not selecting:
		return
	
	_set_selection_state(true)


func _set_selection_state(hover: bool) -> void:
	var rect_abs := _selection_rect.abs()

	for unit: Unit in _visible_units.values():
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
