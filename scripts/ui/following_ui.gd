extends Control
class_name FollowingUi

var target: Node3D

@onready var camera: Camera3D = get_viewport().get_camera_3d()

func _ready() -> void:
	visible = false


func _process(_delta: float) -> void:
	if not visible or target == null:
		return

	var pos := camera.unproject_position(target.global_position)
	position = pos


func set_target(to: Node3D)->void:
	visible = true
	target = to

func close() -> void:
	visible = true
	target = null
