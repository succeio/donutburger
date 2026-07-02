extends Node

# Autoload singleton handling sounds

var music_player: AudioStreamPlayer
var sfx_player_pool: Array[AudioStreamPlayer] = []
var max_sfx_players = 6

func _ready() -> void:
	# Keep playing music across scenes
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Background music
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	var music_stream = load("res://Audio/mus.mp3")
	if music_stream:
		music_player.stream = music_stream
		music_player.volume_db = -12 # Lower volume for bg music
		music_player.autoplay = true
		music_player.bus = "Master"
		music_player.play()
		
	# SFX Pool
	for i in range(max_sfx_players):
		var p = AudioStreamPlayer.new()
		add_child(p)
		sfx_player_pool.append(p)

func play_sfx(sound_path: String, volume_db: float = 0.0) -> void:
	var stream = load(sound_path)
	if not stream:
		return
		
	# Find available player
	for player in sfx_player_pool:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.play()
			return
			
	# Fallback: override first player
	var fallback_player = sfx_player_pool[0]
	fallback_player.stream = stream
	fallback_player.volume_db = volume_db
	fallback_player.play()
