extends Node
## Holds all the sound effects for quick use

var pop_streams: Array[AudioStream] = [
	preload("res://assets/audio/units/pop_1.wav"),
	preload("res://assets/audio/units/pop_2.wav"),
	preload("res://assets/audio/units/pop_3.wav"),
	preload("res://assets/audio/units/pop_4.wav"),
	preload("res://assets/audio/units/pop_5.wav"),
	preload("res://assets/audio/units/pop_6.wav"),
	preload("res://assets/audio/units/pop_7.wav"),
]

var swoosh_streams: Array[AudioStream] = [
	preload("res://assets/audio/units/swoosh_1.wav"),
	preload("res://assets/audio/units/swoosh_2.wav"),
	preload("res://assets/audio/units/swoosh_3.wav"),
	preload("res://assets/audio/units/swoosh_4.wav"),
	preload("res://assets/audio/units/swoosh_5.wav"),
	preload("res://assets/audio/units/swoosh_6.wav"),
	preload("res://assets/audio/units/swoosh_7.wav"),
]

var ding_streams: Array[AudioStream] = [
	preload("res://assets/audio/units/ding_1.wav"),
	preload("res://assets/audio/units/ding_2.wav"),
	preload("res://assets/audio/units/ding_3.wav"),
	preload("res://assets/audio/units/ding_4.wav"),
]

var tok_streams: Array[AudioStream] = [
	preload("res://assets/audio/units/tok_1.wav"),
	preload("res://assets/audio/units/tok_2.wav"),
	preload("res://assets/audio/units/tok_3.wav"),
	preload("res://assets/audio/units/tok_4.wav"),
	preload("res://assets/audio/units/tok_5.wav"),
	preload("res://assets/audio/units/tok_6.wav"),
]


func pop() -> AudioStream:
	return pop_streams.pick_random()


func swoosh() -> AudioStream:
	return swoosh_streams.pick_random()


func ding() -> AudioStream:
	return ding_streams.pick_random()


func tok() -> AudioStream:
	return tok_streams.pick_random()
