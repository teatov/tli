extends FollowingUi
class_name AnthillInfo

var anthill: Anthill

@onready var label: Label = $Panel/Label
@onready var nitwit_button: Button = $Panel/NitwitButton


func _ready() -> void:
	super._ready()
	nitwit_button.pressed.connect(_on_nitwit_button_pressed)


func _process(delta: float) -> void:
	super._process(delta)
	if anthill == null:
		return
	label.text = 'honeydew: ' + str(anthill.honeydew)


func open(at: Anthill) -> void:
	anthill = at
	set_target(anthill.ui_origin)


func close() -> void:
	super.close()
	anthill = null


func _on_nitwit_button_pressed()->void:
	anthill.spawn_nitwit()
