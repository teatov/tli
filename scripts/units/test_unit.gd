extends CharacterBody3D
class_name TestUnit

var selected: bool = false

@onready var selection_sprite: Sprite3D = $SelectionSprite


func _ready() -> void:
	set_selected(false)


func set_selected(on: bool) -> void:
	selected = on
	selection_sprite.visible = selected
