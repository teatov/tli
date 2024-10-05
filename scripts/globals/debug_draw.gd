extends CanvasLayer

var camera: Camera3D
var control: Control = Control.new()

var vectors_to_draw: Array[Dictionary] = []

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

func vector(from: Vector3, to: Vector3, color: Color = Color(1, 0, 0)) -> void:
	if not visible:
		return

	vectors_to_draw.append({"from": from, "to": to, "color": color})

func _draw_vector(from: Vector3, to: Vector3, color: Color = Color.RED) -> void:
	if not visible:
		return

	var start := camera.unproject_position(from)
	var end := camera.unproject_position(to)
	control.draw_line(start, end, color, 2)
	_draw_triangle(end, start.direction_to(end), 5, color)

func _draw_triangle(pos: Vector2, dir: Vector2, size: float, color: Color) -> void:
	var a := pos + dir * size
	var b := pos + dir.rotated(2 * PI / 3) * size
	var c := pos + dir.rotated(4 * PI / 3) * size
	var points := PackedVector2Array([a, b, c])
	control.draw_polygon(points, PackedColorArray([color]))

func _unproject(pos: Vector3) -> Vector2:
	return camera.unproject_position(pos)

func _on_control_draw() -> void:
	for v in vectors_to_draw:
		_draw_vector(v["from"] as Vector3, v["to"] as Vector3, v["color"] as Color)
	vectors_to_draw.clear()
