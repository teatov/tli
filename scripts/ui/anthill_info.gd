extends FollowingUI
class_name AnthillInfo

var _anthill: Anthill

@onready var ant_buy_button: BaseButton = $AntBuyButton
@onready var add_one_button: BaseButton = $AddOneButton
@onready var add_five_button: BaseButton = $AddFiveButton
@onready var add_max_button: BaseButton = $AddMaxButton
@onready var counter: HoneydewCounter = $HoneydewCounter


func _ready() -> void:
	assert(ant_buy_button != null, "ant_buy_button missing!")
	assert(add_one_button != null, "add_one_button missing!")
	assert(add_five_button != null, "add_five_button missing!")
	assert(add_max_button != null, "add_max_button missing!")
	assert(counter != null, "counter missing!")
	super._ready()
	ant_buy_button.pressed.connect(_on_ant_buy_button_pressed)
	add_one_button.pressed.connect(_on_add_one_button_pressed)
	add_five_button.pressed.connect(_on_add_five_button_pressed)
	add_max_button.pressed.connect(_on_add_max_button_pressed)


func _process(delta: float) -> void:
	super._process(delta)
	if _anthill == null or not visible:
		return
	counter.update_counter(_anthill.honeydew)
	add_one_button.disabled = not DebugManager.enabled
	add_one_button.visible = DebugManager.enabled
	add_five_button.disabled = not DebugManager.enabled
	add_five_button.visible = DebugManager.enabled
	add_max_button.disabled = not DebugManager.enabled
	add_max_button.visible = DebugManager.enabled


func open(at: Anthill) -> void:
	visible = true
	_anthill = at
	set_target(_anthill.ui_origin)
	counter.initialize(_anthill.honeydew, _anthill.max_honeydew)
	_open_animation(self)


func close() -> void:
	super.close()
	_anthill = null


func _on_ant_buy_button_pressed() -> void:
	UiManager.buy_ants.open(_anthill)
	close()


func _on_add_one_button_pressed() -> void:
	_anthill.deposit_honeydew(1)


func _on_add_five_button_pressed() -> void:
	_anthill.deposit_honeydew(5)


func _on_add_max_button_pressed() -> void:
	_anthill.deposit_honeydew(_anthill.max_honeydew)
