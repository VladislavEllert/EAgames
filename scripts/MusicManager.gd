extends Node

var music_player: AudioStreamPlayer
var current_volume: float = 0.5 

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.stream = load("res://assets/Music/3d20874f20174bd.mp3")
	music_player.play()

func set_music_volume(value: float) -> void:
	music_player.volume_db = value

func stop_music() -> void:
	music_player.stop()

func start_music() -> void:
	music_player.play()

func fade_out_music(duration: float = 0.5) -> void:
	if music_player and music_player.playing:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, duration)
		await tween.finished
		music_player.stop()
		music_player.volume_db = current_volume 
