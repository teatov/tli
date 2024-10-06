extends Node

@onready var anthill_info: AnthillInfo = $/root/World/UI/AnthillInfo


func _ready() -> void:
	assert(anthill_info != null, "anthill_info missing!")
