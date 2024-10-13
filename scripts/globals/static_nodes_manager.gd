extends Node

@onready var player_anthill: Anthill = $/root/World/Structures/Anthill
@onready var main_camera: MainCamera = $/root/World/MainCamera

@onready var nitwits_holder: Node = $/root/World/Units/Nitwits
@onready var gatherers_holder: Node = $/root/World/Units/Gatherers

@onready var aphids_holder: Node = $/root/World/Units/Aphids

@onready var honeydew_holder: Node = $/root/World/Items/Honeydew

func _ready() -> void:
	assert(player_anthill != null, "player_anthill missing!")
	assert(main_camera != null, "main_camera missing!")
	assert(nitwits_holder != null, "nitwits_holder missing!")
	assert(gatherers_holder != null, "gatherers_holder missing!")
	assert(aphids_holder != null, "aphids_holder missing!")
	assert(honeydew_holder != null, "honeydew_holder missing!")
