extends Node

@onready var anthill_info: AnthillInfo = $/root/World/UI/AnthillInfo
@onready var buy_ants: BuyAnts = $/root/World/UI/BuyAnts
@onready var unit_info: UnitInfo = $/root/World/UI/UnitInfo


func _ready() -> void:
	assert(anthill_info != null, "anthill_info missing!")
	assert(buy_ants != null, "buy_ants missing!")
	assert(unit_info != null, "unit_info missing!")
