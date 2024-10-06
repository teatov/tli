extends ReferenceRect
class_name HoneydewCounter

const RECT_SIZE: float = 16
const RANDOM_OFFSET: float = 10
const GAP: float = 1
const SPRITES_PER_RECT: int = 5

var rects: Array[TextureRect] = []

var max_count: int = 0
var count_per_row: int = 0

var counter_1 := preload("res://assets/textures/gui/honeydew_1.png")
var counter_2 := preload("res://assets/textures/gui/honeydew_2.png")
var counter_3 := preload("res://assets/textures/gui/honeydew_3.png")
var counter_4 := preload("res://assets/textures/gui/honeydew_4.png")
var counter_5 := preload("res://assets/textures/gui/honeydew_5.png")


func _ready() -> void:
	count_per_row = floor(size.x / (RECT_SIZE + GAP))


func initialize(init_count: int, init_max_count: int) -> void:
	max_count = init_max_count
	rects.clear()
	for rect in get_children():
		remove_child(rect)
		rect.queue_free()

	for i in init_max_count:
		var col: int = i % count_per_row
		var row: int = floor(i / count_per_row)
		var rect := _create_rect(col, row)
		rects.append(rect)
	
	update_counter(init_count)


func update_counter(new_count: int) -> void:
	var remainder := new_count % SPRITES_PER_RECT
	var whole := new_count - remainder
	
	for i in range(rects.size()):
		var rect := rects[i]
		var amount := i * SPRITES_PER_RECT
		rect.visible = amount < new_count
		if not rect.visible:
			continue
		if amount < whole:
			rect.texture = counter_5
			continue
		
		match remainder:
			1:
				rect.texture = counter_1
			2:
				rect.texture = counter_2
			3:
				rect.texture = counter_3
			4:
				rect.texture = counter_4
			_:
				rect.texture = counter_5


func _create_rect(col: int, row: int) -> TextureRect:
	var rect := TextureRect.new()
	add_child(rect)
	# rect.visible = false
	rect.texture = counter_5
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.position.x = col * (RECT_SIZE + GAP)
	rect.position.y = row * (RECT_SIZE + GAP)
	rect.size = Vector2(RECT_SIZE, RECT_SIZE)
	return rect
