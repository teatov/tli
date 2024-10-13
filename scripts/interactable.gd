extends CharacterBody3D
class_name Interactable
## A base interactable object that can be hovered over and clicked on

const MIN_DRAG_DISTANCE: float = 15

var _hovered: bool = false
var _mouse_over: bool = false
var _can_interact: bool = true
var _click_start_position: Vector2 = Vector2.ZERO

@onready var hover_indicator: VisualInstance3D = $HoverIndicator


func _ready() -> void:
	assert(hover_indicator != null, "hover_indicator missing!")
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _process(_delta: float) -> void:
	_hovered = HoveringManager.hovered_node == self and _mouse_over
	if not _can_interact:
		_hovered = false
		return
	hover_indicator.visible = _hovered


func _input(event: InputEvent) -> void:
	if not _can_interact:
		return
	if event is InputEventMouseButton and _hovered:
		var button_event := event as InputEventMouseButton
		if button_event.button_index != MOUSE_BUTTON_LEFT:
			return

		if button_event.pressed:
			_click_start_position = button_event.position
		else:
			if (
					(button_event.position - _click_start_position).length()
					< MIN_DRAG_DISTANCE
			):
				_click()


func _click() -> void:
	print(self, " clicked!")


func _on_mouse_entered() -> void:
	_mouse_over = true


func _on_mouse_exited() -> void:
	_mouse_over = false