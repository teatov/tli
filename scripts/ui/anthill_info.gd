extends FollowingUI
class_name AnthillInfo

var anthill: Anthill

@onready var ant_buy_button: BaseButton = $AntBuyButton
@onready var add_one_button: BaseButton = $AddOneButton
@onready var add_five_button: BaseButton = $AddFiveButton
@onready var counter: HoneydewCounter = $HoneydewCounter


func _ready() -> void:
	assert(ant_buy_button != null, "ant_buy_button missing!")
	assert(add_one_button != null, "add_one_button missing!")
	assert(add_five_button != null, "add_five_button missing!")
	assert(counter != null, "counter missing!")
	super._ready()
	ant_buy_button.pressed.connect(_on_ant_buy_button_pressed)
	add_one_button.pressed.connect(_on_add_one_button_pressed)
	add_five_button.pressed.connect(_on_add_five_button_pressed)


func _process(delta: float) -> void:
	super._process(delta)
	if anthill == null or not visible:
		return
	counter.update_counter(anthill.honeydew)
	add_one_button.disabled = not DebugDraw.enabled
	add_one_button.visible = DebugDraw.enabled
	add_five_button.disabled = not DebugDraw.enabled
	add_five_button.visible = DebugDraw.enabled


func open(at: Anthill) -> void:
	visible = true
	anthill = at
	set_target(anthill.ui_origin)
	counter.initialize(anthill.honeydew, anthill.max_honeydew)


func close() -> void:
	super.close()
	anthill = null


func _on_ant_buy_button_pressed() -> void:
	UiManager.buy_ants.open(anthill)
	close()


func _on_add_one_button_pressed() -> void:
	anthill.deposit_honeydew(1)


func _on_add_five_button_pressed() -> void:
	anthill.deposit_honeydew(5)
