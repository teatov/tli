extends CanvasLayer
## Handles displaying debug info.

const LINE_WIDTH: float = 2
const MARKER_RADIUS: float = 0.2
const CIRCLE_RADIUS: float = 3
const DEFAULT_COLOR: Color = Color.RED

var enabled: bool = false

var _control: Control = Control.new()
var _label: RichTextLabel = RichTextLabel.new()

var _vectors_to_draw: Dictionary = {}
var _markers_to_draw: Dictionary = {}
var _circles_to_draw: Dictionary = {}
var _text_to_draw: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 999
	enabled = false
	_control.draw.connect(_on_control_draw)
	_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_control)

	_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)


func _process(_delta: float) -> void:
	if not enabled:
		return
	_control.queue_redraw()

	text("fps", str(Engine.get_frames_per_second()))
	text("draw calls", str(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
	text("camera anim step", str(StaticNodesManager.main_camera.advance_anim_step))
	text("select anim step", str(SelectionManager.advance_anim_step))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug"):
		enabled = not enabled
		visible = enabled


func text(key: String, value: String) -> void:
	if not enabled:
		return

	_text_to_draw[key] = value


func vector(
		key: String,
		from: Vector3,
		to: Vector3,
		color: Color = DEFAULT_COLOR,
) -> void:
	if not enabled:
		return

	_vectors_to_draw[key] = {"from": from, "to": to, "color": color, "on": true}


func marker(
		key: String,
		pos: Vector3,
		radius: float = MARKER_RADIUS,
		color: Color = DEFAULT_COLOR,
) -> void:
	if not enabled:
		return

	_markers_to_draw[key] = {"pos": pos, "radius": radius, "color": color, "on": true}


func circle(
		key: String,
		pos: Vector3,
		color: Color = DEFAULT_COLOR,
) -> void:
	if not enabled:
		return

	_circles_to_draw[key] = {"pos": pos, "color": color, "on": true}


func _unproject(pos: Vector3) -> Vector2:
	return StaticNodesManager.main_camera.unproject_position(pos)


func _draw_text(key: String, value: String) -> void:
	_label.text += key + ": " + value + "\n"


func _draw_vector(from: Vector3, to: Vector3, color: Color) -> void:
	var start := _unproject(from)
	var end := _unproject(to)
	_control.draw_line(start, end, color, LINE_WIDTH)
	_draw_triangle(end, start.direction_to(end), 5, color)


func _draw_triangle(
		pos: Vector2,
		dir: Vector2,
		size: float,
		color: Color,
) -> void:
	var a := pos + dir * size
	var b := pos + dir.rotated(2 * PI / 3) * size
	var c := pos + dir.rotated(4 * PI / 3) * size
	var points := PackedVector2Array([a, b, c])
	_control.draw_polygon(points, PackedColorArray([color]))


func _draw_marker(pos: Vector3, radius: float, color: Color) -> void:
	var x_start := _unproject(pos + (Vector3.LEFT * radius))
	var x_end := _unproject(pos + (Vector3.RIGHT * radius))
	_control.draw_line(x_start, x_end, color, LINE_WIDTH)

	var y_start := _unproject(pos + (Vector3.UP * radius))
	var y_end := _unproject(pos + (Vector3.DOWN * radius))
	_control.draw_line(y_start, y_end, color, LINE_WIDTH)

	var z_start := _unproject(pos + (Vector3.FORWARD * radius))
	var z_end := _unproject(pos + (Vector3.BACK * radius))
	_control.draw_line(z_start, z_end, color, LINE_WIDTH)


func _draw_circle(pos: Vector3, color: Color) -> void:
	var point := _unproject(pos)
	_control.draw_circle(point, CIRCLE_RADIUS, color)


func _on_control_draw() -> void:
	if not enabled:
		return

	for v: Dictionary in _vectors_to_draw.values():
		if v["on"]:
			_draw_vector(
					v["from"] as Vector3,
					v["to"] as Vector3,
					v["color"] as Color,
			)
			v["on"] = false

	for v: Dictionary in _markers_to_draw.values():
		if v["on"]:
			_draw_marker(
					v["pos"] as Vector3,
					v["radius"] as float,
					v["color"] as Color,
			)
			v["on"] = false

	for v: Dictionary in _circles_to_draw.values():
		if v["on"]:
			_draw_circle(v["pos"] as Vector3, v["color"] as Color)
			v["on"] = false

	_label.text = ""
	for k: String in _text_to_draw.keys():
		var v: String = _text_to_draw[k]
		_draw_text(k, v)
