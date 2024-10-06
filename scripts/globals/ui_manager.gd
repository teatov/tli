extends Node

@onready var anthill_info: AnthillInfo = $/root/World/UI/AnthillInfo
@onready var buy_ants: BuyAnts = $/root/World/UI/BuyAnts


func _ready() -> void:
	assert(anthill_info != null, "anthill_info missing!")
	assert(buy_ants != null, "buy_ants missing!")
