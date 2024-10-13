extends CharacterBody3D
class_name Interactable
## A base interactable object that can be hovered over and clicked on

const MIN_DRAG_DISTANCE: float = 15

var hovered: bool = false
var mouse_over: bool = false
var can_interact: bool = true
var click_position: Vector2 = Vector2.ZERO

@onready var hover_indicator: VisualInstance3D = $HoverIndicator


func _ready() -> void:
	assert(hover_indicator != null, "hover_indicator missing!")
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _process(_delta: float) -> void:
	hovered = HoveringManager.hovered_node == self and mouse_over
	if not can_interact:
		hovered = false
		return
	hover_indicator.visible = hovered


func _input(event: InputEvent) -> void:
	if not can_interact:
		return
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


func _on_mouse_entered() -> void:
	mouse_over = true


func _on_mouse_exited() -> void:
	mouse_over = false