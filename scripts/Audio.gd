extends Node2D

var sound_library = {
	"start_rope": ["res://assets/sound/start_rope.wav", -5],
	"end_rope": ["res://assets/sound/end_rope.wav", -5],
	"create_rope": ["res://assets/sound/create_rope.wav", -5]
}

var music_path = preload("res://assets/sound/your-call-by-kevin-macleod-from-filmmusic-io.mp3")

var music_volume = -20

var stream_library = {}

func _ready():
	for key in sound_library:
		var sound_node = AudioStreamPlayer.new()
		var stream  = load(sound_library[key][0])
		sound_node.set_stream(stream)
		sound_node.volume_db = sound_library[key][1]
		sound_node.set_bus("FX")
		add_child(sound_node)
		stream_library[key] = sound_node
	$Music.volume_db = music_volume
	$Music.set_stream(music_path)
	$Music.play()

func play_sound(sound_str):
	if sound_str in stream_library:
		stream_library[sound_str].play()
