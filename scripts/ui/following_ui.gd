extends CloseableUI
class_name FollowingUI

const EDGE_MARGIN = 10

var _target: Node3D


func _process(_delta: float) -> void:
	if not visible or _target == null:
		return

	var pos := StaticNodesManager.main_camera.unproject_position(
			_target.global_position
	)
	var corner_1 := Vector2.ONE * EDGE_MARGIN
	var viewport_size := get_viewport().get_visible_rect().size
	var corner_2 := Vector2(
			viewport_size.x - size.x - EDGE_MARGIN,
			viewport_size.y - size.y - EDGE_MARGIN,
	)
	position = (pos - pivot_offset).clamp(corner_1, corner_2)


func set_target(to: Node3D) -> void:
	_target = to


func close() -> void:
	super.close()
	_target = null
