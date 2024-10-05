extends CanvasLayer

const LINE_WIDTH: float = 2
const MARKER_RADIUS: float = 0.2
const CIRCLE_RADIUS: float = 3
const DEFAULT_COLOR: Color = Color.RED

var camera: Camera3D
var control: Control = Control.new()

var vectors_to_draw: Array[Dictionary] = []
var markers_to_draw: Array[Dictionary] = []
var circles_to_draw: Array[Dictionary] = []


func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	layer = 999
	visible = false
	control.draw.connect(_on_control_draw)
	add_child(control)


func _process(_delta: float) -> void:
	if not visible:
		return
	control.queue_redraw()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug"):
		visible = not visible
		vectors_to_draw.clear()


func vector(from: Vector3, to: Vector3, color: Color = DEFAULT_COLOR) -> void:
	if not visible:
		return

	vectors_to_draw.append({"from": from, "to": to, "color": color})


func marker(pos: Vector3, radius: float = MARKER_RADIUS, color: Color = DEFAULT_COLOR) -> void:
	if not visible:
		return

	markers_to_draw.append({"pos": pos, "radius": radius, "color": color})


func circle(pos: Vector3, color: Color = DEFAULT_COLOR) -> void:
	if not visible:
		return

	circles_to_draw.append({"pos": pos, "color": color})


func _unproject(pos: Vector3) -> Vector2:
	return camera.unproject_position(pos)


func _draw_vector(from: Vector3, to: Vector3, color: Color) -> void:
	var start := _unproject(from)
	var end := _unproject(to)
	control.draw_line(start, end, color, LINE_WIDTH)
	_draw_triangle(end, start.direction_to(end), 5, color)


func _draw_triangle(pos: Vector2, dir: Vector2, size: float, color: Color) -> void:
	var a := pos + dir * size
	var b := pos + dir.rotated(2 * PI / 3) * size
	var c := pos + dir.rotated(4 * PI / 3) * size
	var points := PackedVector2Array([a, b, c])
	control.draw_polygon(points, PackedColorArray([color]))


func _draw_marker(pos: Vector3, radius: float, color: Color) -> void:
	var x_start := _unproject(pos + (Vector3.LEFT * radius))
	var x_end := _unproject(pos + (Vector3.RIGHT * radius))
	control.draw_line(x_start, x_end, color, LINE_WIDTH)

	var y_start := _unproject(pos + (Vector3.UP * radius))
	var y_end := _unproject(pos + (Vector3.DOWN * radius))
	control.draw_line(y_start, y_end, color, LINE_WIDTH)

	var z_start := _unproject(pos + (Vector3.FORWARD * radius))
	var z_end := camera.unproject_position(pos + (Vector3.BACK * radius))
	control.draw_line(z_start, z_end, color, LINE_WIDTH)


func _draw_circle(pos: Vector3, color: Color) -> void:
	var point := camera.unproject_position(pos)
	control.draw_circle(point, CIRCLE_RADIUS, color)


func _on_control_draw() -> void:
	if not visible:
		return

	for v in vectors_to_draw:
		_draw_vector(v["from"] as Vector3, v["to"] as Vector3, v["color"] as Color)
	vectors_to_draw.clear()

	for v in markers_to_draw:
		_draw_marker(v["pos"] as Vector3, v["radius"] as float, v["color"] as Color)
	markers_to_draw.clear()

	for v in circles_to_draw:
		_draw_circle(v["pos"] as Vector3, v["color"] as Color)
	circles_to_draw.clear()
