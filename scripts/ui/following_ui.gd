extends CloseableUI
class_name FollowingUI

const EDGE_MARGIN = 10

var target: Node3D

@onready var camera: Camera3D = get_viewport().get_camera_3d()

func _ready() -> void:
	assert(camera != null, "camera missing!")
	super._ready()


func _process(_delta: float) -> void:
	if not visible or target == null:
		return

	var pos := camera.unproject_position(target.global_position)
	var corner_1 := Vector2.ONE * EDGE_MARGIN
	var viewport_size := get_viewport().get_visible_rect().size
	var corner_2 := Vector2(
			viewport_size.x - size.x - EDGE_MARGIN,
			viewport_size.y - size.y - EDGE_MARGIN,
	)
	position = (pos - pivot_offset).clamp(corner_1, corner_2)


func set_target(to: Node3D) -> void:
	target = to


func close() -> void:
	super.close()
	target = null
