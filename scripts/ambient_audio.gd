extends AudioStreamPlayer

const ZOOMED_IN_CUTOFF = 10000
const ZOOMED_OUT_CUTOFF = 0

var audio_1 := preload("res://assets/audio/ambient/ambient_1.ogg")
var audio_2 := preload("res://assets/audio/ambient/ambient_2.ogg")
var audio_3 := preload("res://assets/audio/ambient/ambient_3.ogg")

var streams: Array[AudioStream] = [audio_1, audio_2, audio_3]
var filter: AudioEffectHighPassFilter


func _ready() -> void:
	var bus_idx := AudioServer.get_bus_index(bus)
	for effect_idx in AudioServer.get_bus_effect_count(bus_idx):
		var effect := AudioServer.get_bus_effect(bus_idx, effect_idx)
		if effect is AudioEffectHighPassFilter:
			filter = effect
	assert(filter != null, "filter missing!")

	stream = streams.pick_random()
	play()


func _process(_delta: float) -> void:
	filter.cutoff_hz = lerpf(
			ZOOMED_IN_CUTOFF,
			ZOOMED_OUT_CUTOFF,
			StaticNodesManager.main_camera.zoom_value,
	)
