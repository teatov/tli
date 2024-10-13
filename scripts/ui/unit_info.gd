extends FollowingUI
class_name UnitInfo

enum State {
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

var _unit: Unit
var _state: State = State.NONE
var _anim_time: float = 0

@onready var texture_rect: TextureRect = $TextureRect
@onready var atlas: AtlasTexture = texture_rect.texture as AtlasTexture


func _ready() -> void:
	assert(texture_rect != null, "texture_rect missing!")
	assert(atlas != null, "atlas missing!")
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	if _unit == null or not visible:
		return

	_anim_time += delta
	
	_get_state()
	_handle_pictogram()


func open(who: Unit) -> void:
	if _unit != null:
		close()
	visible = true
	_unit = who
	set_target(_unit.ui_origin)


func close() -> void:
	_unit.toggle_info(false)
	super.close()


func _handle_pictogram() -> void:
	texture_rect.visible = _state != State.NONE
	atlas.region.position.y = (_state - 1) * atlas.region.size.y
	atlas.region.position.x = floorf(
			wrapf(_anim_time / ANIMATION_SPEED, 0, 4)
	) * atlas.region.size.x
	
func _get_state() -> void:
	if _unit is Aphid:
		match (_unit as Aphid).state:
			Aphid.State.WANDERING:
				_state = State.APHID_IDLE
	
	if _unit is AntNitwit:
		match (_unit as AntNitwit).state:
			AntNitwit.State.WANDERING:
				_state = State.ANT_IDLE
			AntNitwit.State.MOVING:
				_state = State.ANT_MOVING
			AntNitwit.State.GATHERING:
				_get_gathering_state((_unit as AntNitwit).gathering.state)

	if _unit is AntGatherer:
		match (_unit as AntGatherer).state:
			AntGatherer.State.WANDERING:
				_state = State.ANT_IDLE
			AntGatherer.State.MOVING:
				_state = State.ANT_MOVING
			AntGatherer.State.GATHERING:
				_get_gathering_state((_unit as AntGatherer).gathering.state)


func _get_gathering_state(gather_state: Gathering.State) -> void:
	match gather_state:
		Gathering.State.PICKING_UP:
			_state = State.ANT_PICKING_UP
		Gathering.State.DEPOSITING:
			_state = State.ANT_DEPOSITING
		Gathering.State.AWAITING:
			_state = State.ANT_AWAITING
		Gathering.State.STOP:
			_state = State.NONE
