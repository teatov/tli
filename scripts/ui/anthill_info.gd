extends FollowingUi
class_name AnthillInfo

var anthill: Anthill

@onready var label: Label = $Panel/Label
@onready var nitwit_button: Button = $Panel/NitwitButton
@onready var add_one_button: Button = $Panel/AddOneButton
@onready var counter: HoneydewCounter = $Panel/HoneydewCounter


func _ready() -> void:
	assert(label != null, "label missing!")
	assert(nitwit_button != null, "nitwit_button missing!")
	assert(add_one_button != null, "add_one_button missing!")
	assert(counter != null, "counter missing!")
	super._ready()
	nitwit_button.pressed.connect(_on_nitwit_button_pressed)
	add_one_button.pressed.connect(_on_add_one_button_pressed)


func _process(delta: float) -> void:
	super._process(delta)
	if anthill == null or not visible:
		return
	label.text = 'honeydew: ' + str(anthill.honeydew)
	counter.update_counter(anthill.honeydew)


func open(at: Anthill) -> void:
	anthill = at
	set_target(anthill.ui_origin)
	counter.initialize(anthill.honeydew, anthill.max_honeydew)


func close() -> void:
	super.close()
	anthill = null


func _on_nitwit_button_pressed() -> void:
	anthill.spawn_nitwit()


func _on_add_one_button_pressed() -> void:
	anthill.honeydew += 1