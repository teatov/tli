extends ReferenceRect
class_name HoneydewCounter

const RECT_SIZE: float = 16
const RANDOM_OFFSET: float = 5
const GAP: float = 1
const SPRITES_PER_RECT: int = 5

@export var _atlas: AtlasTexture

var _rects: Array[TextureRect] = []

var _max_count: int = 0
var _count_per_row: int = 0
var _rect_size: float = RECT_SIZE


func _ready() -> void:
	assert(_atlas != null, "_atlas missing!")
	_count_per_row = floori(size.x / (_rect_size + GAP))


func initialize(
		init_count: int,
		init_max_count: int,
		r_size: float = RECT_SIZE,
) -> void:
	_max_count = init_max_count
	_rect_size = r_size
	_rects.clear()
	for rect in get_children():
		remove_child(rect)
		rect.queue_free()

	for i in (ceil(init_max_count / SPRITES_PER_RECT) as int):
		var col: int = i % _count_per_row
		var row: int = floori(i / _count_per_row)
		var rect := _create_rect(col, row)
		_rects.append(rect)
	
	update_counter(init_count)


func update_counter(new_count: int) -> void:
	var remainder := new_count % SPRITES_PER_RECT
	var whole := new_count - remainder
	
	for i in range(_rects.size()):
		var rect := _rects[i]
		var amount := i * SPRITES_PER_RECT
		var count: int = 0
		if amount >= new_count:
			count = 0
		elif amount < whole:
			count = 5
		else:
			count = remainder
		
		(rect.texture as AtlasTexture).region.position.x = count * _atlas.region.size.x


func _create_rect(col: int, row: int) -> TextureRect:
	var rect := TextureRect.new()
	add_child(rect)
	rect.texture = _atlas.duplicate()
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.position.x = (
			col
			* (_rect_size + GAP)
			+ randf_range(-RANDOM_OFFSET, RANDOM_OFFSET)
	)
	rect.position.y = (
			row
			* (_rect_size + GAP)
			+ randf_range(-RANDOM_OFFSET, RANDOM_OFFSET)
	)
	rect.size = Vector2(_rect_size, _rect_size)
	return rect
