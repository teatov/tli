extends FollowingUI
class_name BuyAnts

const COUNTER_SIZE: float = 32

var _anthill: Anthill

@onready var buy_nitwit_button: BaseButton = $BuyNitwitButton
@onready var nitwit_price_counter: HoneydewCounter = $NitwitPriceCounter

@onready var buy_gatherer_button: BaseButton = $BuyGathererButton
@onready var gatherer_price_counter: HoneydewCounter = $GathererPriceCounter

@onready var counter: HoneydewCounter = $HoneydewCounter


func _ready() -> void:
	assert(buy_nitwit_button != null, "buy_nitwit_button missing!")
	assert(nitwit_price_counter != null, "nitwit_price_counter missing!")
	assert(buy_gatherer_button != null, "buy_gatherer_button missing!")
	assert(gatherer_price_counter != null, "gatherer_price_counter missing!")
	assert(counter != null, "counter missing!")
	super._ready()
	buy_nitwit_button.pressed.connect(_on_buy_nitwit_button_pressed)
	buy_gatherer_button.pressed.connect(_on_buy_gatherer_button_pressed)


func _process(delta: float) -> void:
	super._process(delta)
	if _anthill == null or not visible:
		return
	counter.update_counter(_anthill.honeydew)


func open(at: Anthill) -> void:
	visible = true
	_anthill = at
	nitwit_price_counter.initialize(
			AntNitwit.get_cost(),
			AntNitwit.get_cost(),
			COUNTER_SIZE,
	)
	gatherer_price_counter.initialize(
			AntGatherer.get_cost(),
			AntGatherer.get_cost(),
			COUNTER_SIZE,
	)
	set_target(_anthill.ui_origin)
	counter.initialize(_anthill.honeydew, _anthill.max_honeydew)
	_open_animation(self)


func close() -> void:
	super.close()
	_anthill = null


func _on_buy_nitwit_button_pressed() -> void:
	_anthill.spawn_nitwit()


func _on_buy_gatherer_button_pressed() -> void:
	_anthill.spawn_gatherer()
