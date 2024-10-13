extends FollowingUI
class_name BuyAnts

const COUNTER_SIZE:float = 32

var anthill: Anthill

@onready var buy_nitwit_button: BaseButton = $BuyNitwitButton
@onready var nitwit_price_counter: HoneydewCounter = $NitwitPriceCounter
@onready var nitwit_info: Control = $NitwitPanel

@onready var buy_gatherer_button: BaseButton = $BuyGathererButton
@onready var gatherer_price_counter: HoneydewCounter = $GathererPriceCounter
@onready var gatherer_info: Control = $GathererPanel

@onready var counter: HoneydewCounter = $HoneydewCounter


func _ready() -> void:
	assert(buy_nitwit_button != null, "buy_nitwit_button missing!")
	assert(nitwit_price_counter != null, "nitwit_price_counter missing!")
	assert(nitwit_info != null, "nitwit_info missing!")
	assert(buy_gatherer_button != null, "buy_gatherer_button missing!")
	assert(gatherer_price_counter != null, "gatherer_price_counter missing!")
	assert(gatherer_info != null, "gatherer_info missing!")
	assert(counter != null, "counter missing!")
	super._ready()
	buy_nitwit_button.pressed.connect(_on_buy_nitwit_button_pressed)
	nitwit_info.visible = false
	buy_gatherer_button.pressed.connect(_on_buy_gatherer_button_pressed)
	gatherer_info.visible = false


func _process(delta: float) -> void:
	super._process(delta)
	if anthill == null or not visible:
		return
	counter.update_counter(anthill.honeydew)
	nitwit_info.visible = buy_nitwit_button.is_hovered()
	gatherer_info.visible = buy_gatherer_button.is_hovered()


func open(at: Anthill) -> void:
	visible = true
	anthill = at
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
	set_target(anthill.ui_origin)
	counter.initialize(anthill.honeydew, anthill.max_honeydew)


func close() -> void:
	super.close()
	anthill = null

func _on_buy_nitwit_button_pressed() -> void:
	anthill.spawn_nitwit()

func _on_buy_gatherer_button_pressed() -> void:
	anthill.spawn_gatherer()
