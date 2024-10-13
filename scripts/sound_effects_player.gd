extends AudioStreamPlayer3D
class_name SoundEffectsPlayer
## Wrapper of AudioStreamPlayer3D that has AudioStreamPlaybackPolyphonic.

var _playback: AudioStreamPlaybackPolyphonic


func _ready() -> void:
	stream = AudioStreamPolyphonic.new()
	play()
	_playback = get_stream_playback()


func play_sound(
		new_stream: AudioStream,
		from_offset: float = 0,
		new_volume_db: float = 0,
		new_pitch_scale: float = 1.0,
) -> void:
	_playback.play_stream(
			new_stream,
			from_offset,
			new_volume_db,
			new_pitch_scale,
	)
