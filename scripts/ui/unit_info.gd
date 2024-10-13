extends FollowingUI
class_name UnitInfo

enum InfoState {
	NONE,
	ANT_IDLE,
	ANT_MOVING,
	ANT_PICKING_UP,
	ANT_DEPOSITING,
	ANT_AWAITING,
	APHID_IDLE,
	APHID_PANIC,
	APHID_EAT,
}

const ANIMATION_SPEED: float = 0.25

var unit: Unit
var state: InfoState = InfoState.NONE
var anim_time: float = 0

@onready var texture_rect: TextureRect = $TextureRect
@onready var atlas: AtlasTexture = texture_rect.texture as AtlasTexture


func _ready() -> void:
	assert(texture_rect != null, "texture_rect missing!")
	assert(atlas != null, "atlas missing!")
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	if unit == null or not visible:
		return

	anim_time += delta
	
	_get_state()
	_handle_pictogram()


func open(who: Unit) -> void:
	if unit != null:
		close()
	visible = true
	unit = who
	set_target(unit.ui_origin)


func close() -> void:
	unit.toggle_info(false)
	super.close()


func _handle_pictogram() -> void:
	texture_rect.visible = state != InfoState.NONE
	atlas.region.position.y = (state - 1) * atlas.region.size.y
	atlas.region.position.x = floor(
			wrapf(anim_time / ANIMATION_SPEED, 0, 4)
	) * atlas.region.size.x
	
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
				_get_gathering_state((unit as AntNitwit).gathering.state)
	
	if unit is AntGatherer:
		match (unit as AntGatherer).state:
			AntGatherer.AntGathererState.WANDERING:
				state = InfoState.ANT_IDLE
			AntGatherer.AntGathererState.MOVING:
				state = InfoState.ANT_MOVING
			AntGatherer.AntGathererState.GATHERING:
				_get_gathering_state((unit as AntGatherer).gathering.state)


func _get_gathering_state(gather_state: Gathering.GatherState) -> void:
	match gather_state:
		Gathering.GatherState.PICKING_UP:
			state = InfoState.ANT_PICKING_UP
		Gathering.GatherState.DEPOSITING:
			state = InfoState.ANT_DEPOSITING
		Gathering.GatherState.AWAITING:
			state = InfoState.ANT_AWAITING
		Gathering.GatherState.STOP:
			state = InfoState.NONE
