extends Node

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


func pop() -> AudioStream:
	return pop_streams.pick_random() as AudioStream


func swoosh() -> AudioStream:
	return swoosh_streams.pick_random() as AudioStream
