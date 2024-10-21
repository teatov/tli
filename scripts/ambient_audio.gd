extends AudioStreamPlayer

const ZOOMED_IN_CUTOFF = 10000
const ZOOMED_OUT_CUTOFF = 0

var _audio_1 := preload("res://assets/audio/ambient/ambient_1.ogg")
var _audio_2 := preload("res://assets/audio/ambient/ambient_2.ogg")
var _audio_3 := preload("res://assets/audio/ambient/ambient_3.ogg")

var _streams: Array[AudioStream] = [_audio_1, _audio_2, _audio_3]
var _filter: AudioEffectHighPassFilter


func _ready() -> void:
	var bus_idx := AudioServer.get_bus_index(bus)
	for effect_idx in AudioServer.get_bus_effect_count(bus_idx):
		var effect := AudioServer.get_bus_effect(bus_idx, effect_idx)
		if effect is AudioEffectHighPassFilter:
			_filter = effect
	assert(_filter != null, "_filter missing!")

	stream = _streams.pick_random()
	play()


func _process(_delta: float) -> void:
	_filter.cutoff_hz = lerpf(
			ZOOMED_IN_CUTOFF,
			ZOOMED_OUT_CUTOFF,
			ease(StaticNodesManager.main_camera.zoom_value, 0.5),
	)
