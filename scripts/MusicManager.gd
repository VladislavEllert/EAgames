extends Node

var music_player: AudioStreamPlayer

func _ready() -> void:
	# Создаём плеер, который не уничтожится при смене сцены
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
