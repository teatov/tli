extends ReferenceRect
class_name HoneydewCounter

const RECT_SIZE: float = 16
const RANDOM_OFFSET: float = 5
const GAP: float = 1
const SPRITES_PER_RECT: int = 5

@export var atlas: AtlasTexture

var rects: Array[TextureRect] = []

var max_count: int = 0
var count_per_row: int = 0
var rect_size: float = RECT_SIZE


func _ready() -> void:
	assert(atlas != null, "atlas missing!")
	count_per_row = floori(size.x / (rect_size + GAP))


func initialize(
		init_count: int,
		init_max_count: int,
		r_size: float = RECT_SIZE,
) -> void:
	max_count = init_max_count
	rect_size = r_size
	rects.clear()
	for rect in get_children():
		remove_child(rect)
		rect.queue_free()

	for i in (ceil(init_max_count / SPRITES_PER_RECT) as int):
		var col: int = i % count_per_row
		var row: int = floori(i / count_per_row)
		var rect := _create_rect(col, row)
		rects.append(rect)
	
	update_counter(init_count)


func update_counter(new_count: int) -> void:
	var remainder := new_count % SPRITES_PER_RECT
	var whole := new_count - remainder
	
	for i in range(rects.size()):
		var rect := rects[i]
		var amount := i * SPRITES_PER_RECT
		var count: int = 0
		if amount >= new_count:
			count = 0
		elif amount < whole:
			count = 5
		else:
			count = remainder
		
		(rect.texture as AtlasTexture).region.position.x = count * atlas.region.size.x


func _create_rect(col: int, row: int) -> TextureRect:
	var rect := TextureRect.new()
	add_child(rect)
	rect.texture = atlas.duplicate()
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.position.x = (
			col
			* (rect_size + GAP)
			+ randf_range(-RANDOM_OFFSET, RANDOM_OFFSET)
	)
	rect.position.y = (
			row
			* (rect_size + GAP)
			+ randf_range(-RANDOM_OFFSET, RANDOM_OFFSET)
	)
	rect.size = Vector2(rect_size, rect_size)
	return rect
