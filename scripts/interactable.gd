extends StaticBody3D
class_name Interactable

const MIN_DRAG_DISTANCE: float = 15

var hovered: bool = false
var click_position: Vector2 = Vector2.ZERO

@onready var hover_sprite: Sprite3D = $HoverSprite


func _ready() -> void:
	assert(hover_sprite != null, "hover_sprite missing!")


func _process(_delta: float) -> void:
	hovered = HoveringManager.hovered_node == self
	_animate()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and hovered:
		var button_event := event as InputEventMouseButton
		if button_event.button_index != MOUSE_BUTTON_LEFT:
			return

		if button_event.pressed:
			click_position = button_event.position
		else:
			if (
					(button_event.position - click_position).length()
					< MIN_DRAG_DISTANCE
			):
				_click()


func _click() -> void:
	print(self, ' clicked!')


func _animate() -> void:
	hover_sprite.visible = hovered

