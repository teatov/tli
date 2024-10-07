extends FollowingUI
class_name UnitInfo

enum InfoState {
	NONE,
	ANT_IDLE,
	ANT_MOVING,
	ANT_PICKING_UP,
	ANT_DEPOSITING,
	APHID_IDLE,
	APHID_PANIC,
	APHID_EAT,
}

var unit: Unit
var state: InfoState = InfoState.NONE

@onready var ant_idle: Control = $AntIdle
@onready var ant_moving: Control = $AntMoving
@onready var ant_picking_up: Control = $AntPickingUp
@onready var ant_depositing: Control = $AntDepositing
@onready var aphid_idle: Control = $AphidIdle
@onready var aphid_panic: Control = $AphidPanic
@onready var aphid_eat: Control = $AphidEat


func _ready() -> void:
	assert(ant_idle != null, "ant_idle missing!")
	assert(ant_moving != null, "ant_moving missing!")
	assert(ant_picking_up != null, "ant_picking_up missing!")
	assert(ant_depositing != null, "ant_depositing missing!")
	assert(aphid_idle != null, "aphid_idle missing!")
	assert(aphid_panic != null, "aphid_panic missing!")
	assert(aphid_eat != null, "aphid_eat missing!")
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	if unit == null or not visible:
		return
	
	_get_state()
	_set_image()


func open(who: Unit) -> void:
	if unit != null:
		close()
	visible = true
	unit = who
	set_target(unit.ui_origin)


func close() -> void:
	unit.toggle_info(false)
	super.close()


func _set_image()->void:
	for child:Control in get_children():
		child.visible = false

	match state:
		InfoState.ANT_IDLE:
			ant_idle.visible = true
		InfoState.ANT_MOVING:
			ant_moving.visible = true
		InfoState.ANT_PICKING_UP:
			ant_picking_up.visible = true
		InfoState.ANT_DEPOSITING:
			ant_depositing.visible = true
		InfoState.APHID_IDLE:
			aphid_idle.visible = true
		InfoState.APHID_PANIC:
			aphid_panic.visible = true
		InfoState.APHID_EAT:
			aphid_eat.visible = true
	
	
func _get_state() -> void:
	if unit is Aphid:
		match (unit as Aphid).state:
			Aphid.AphidState.WANDERING:
				state = InfoState.APHID_IDLE
	
	if unit is AntNitwit:
		match (unit as AntNitwit).state:
			AntNitwit.AntNitwitState.WANDERING:
				state = InfoState.ANT_IDLE
			AntNitwit.AntNitwitState.MOVING:
				state = InfoState.ANT_MOVING
			AntNitwit.AntNitwitState.GATHERING:
				match (unit as AntNitwit).gathering.state:
					Gathering.GatherState.PICKING_UP:
						state = InfoState.ANT_PICKING_UP
					Gathering.GatherState.DEPOSITING:
						state = InfoState.ANT_DEPOSITING
					Gathering.GatherState.STOP:
						state = InfoState.NONE
	
	if unit is AntGatherer:
		match (unit as AntGatherer).state:
			AntGatherer.AntGathererState.WANDERING:
				state = InfoState.ANT_IDLE
			AntGatherer.AntGathererState.MOVING:
				state = InfoState.ANT_MOVING
			AntGatherer.AntGathererState.GATHERING:
				match (unit as AntGatherer).gathering.state:
					Gathering.GatherState.PICKING_UP:
						state = InfoState.ANT_PICKING_UP
					Gathering.GatherState.DEPOSITING:
						state = InfoState.ANT_DEPOSITING
					Gathering.GatherState.STOP:
						state = InfoState.NONE
