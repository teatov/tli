extends Node
## Holds all the sound effects for quick use.

var audio_player: SoundEffectsPlayer = SoundEffectsPlayer.new()

var _pop_streams: Array[AudioStream] = [
	preload("res://assets/audio/units/pop_1.wav"),
	preload("res://assets/audio/units/pop_2.wav"),
	preload("res://assets/audio/units/pop_3.wav"),
	preload("res://assets/audio/units/pop_4.wav"),
	preload("res://assets/audio/units/pop_5.wav"),
	preload("res://assets/audio/units/pop_6.wav"),
	preload("res://assets/audio/units/pop_7.wav"),
]

var _swoosh_streams: Array[AudioStream] = [
	preload("res://assets/audio/units/swoosh_1.wav"),
	preload("res://assets/audio/units/swoosh_2.wav"),
	preload("res://assets/audio/units/swoosh_3.wav"),
	preload("res://assets/audio/units/swoosh_4.wav"),
	preload("res://assets/audio/units/swoosh_5.wav"),
	preload("res://assets/audio/units/swoosh_6.wav"),
	preload("res://assets/audio/units/swoosh_7.wav"),
]

var _ding_streams: Array[AudioStream] = [
	preload("res://assets/audio/units/ding_1.wav"),
	preload("res://assets/audio/units/ding_2.wav"),
	preload("res://assets/audio/units/ding_3.wav"),
	preload("res://assets/audio/units/ding_4.wav"),
]

var _tok_streams: Array[AudioStream] = [
	preload("res://assets/audio/units/tok_1.wav"),
	preload("res://assets/audio/units/tok_2.wav"),
	preload("res://assets/audio/units/tok_3.wav"),
	preload("res://assets/audio/units/tok_4.wav"),
	preload("res://assets/audio/units/tok_5.wav"),
	preload("res://assets/audio/units/tok_6.wav"),
]

var _hover_streams: Array[AudioStream] = [
	preload("res://assets/audio/ui/hover_1.wav"),
	preload("res://assets/audio/ui/hover_2.wav"),
	preload("res://assets/audio/ui/hover_3.wav"),
	preload("res://assets/audio/ui/hover_4.wav"),
	preload("res://assets/audio/ui/hover_5.wav"),
	preload("res://assets/audio/ui/hover_6.wav"),
]

var _press_down_streams: Array[AudioStream] = [
	preload("res://assets/audio/ui/press_down_1.wav"),
	preload("res://assets/audio/ui/press_down_2.wav"),
	preload("res://assets/audio/ui/press_down_3.wav"),
	preload("res://assets/audio/ui/press_down_4.wav"),
	preload("res://assets/audio/ui/press_down_5.wav"),
	preload("res://assets/audio/ui/press_down_6.wav"),
]

var _press_up_streams: Array[AudioStream] = [
	preload("res://assets/audio/ui/press_up_1.wav"),
	preload("res://assets/audio/ui/press_up_2.wav"),
	preload("res://assets/audio/ui/press_up_3.wav"),
	preload("res://assets/audio/ui/press_up_4.wav"),
	preload("res://assets/audio/ui/press_up_5.wav"),
	preload("res://assets/audio/ui/press_up_6.wav"),
]

var _aphid_poop_streams: Array[AudioStream] = [
	preload("res://assets/audio/units/aphid_poop_1.wav"),
	preload("res://assets/audio/units/aphid_poop_2.wav"),
	preload("res://assets/audio/units/aphid_poop_3.wav"),
	preload("res://assets/audio/units/aphid_poop_4.wav"),
	preload("res://assets/audio/units/aphid_poop_5.wav"),
	preload("res://assets/audio/units/aphid_poop_6.wav"),
]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	audio_player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_DISABLED
	audio_player.panning_strength = 0
	audio_player.stream_paused = true
	add_child(audio_player)


func pop() -> AudioStream:
	return _pop_streams.pick_random()


func swoosh() -> AudioStream:
	return _swoosh_streams.pick_random()


func ding() -> AudioStream:
	return _ding_streams.pick_random()


func tok() -> AudioStream:
	return _tok_streams.pick_random()


func hover() -> AudioStream:
	return _hover_streams.pick_random()


func press_down() -> AudioStream:
	return _press_down_streams.pick_random()


func press_up() -> AudioStream:
	return _press_up_streams.pick_random()


func aphid_poop() -> AudioStream:
	return _aphid_poop_streams.pick_random()
