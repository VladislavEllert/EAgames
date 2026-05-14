extends Node

var music_player: AudioStreamPlayer
var music_volume: float = 0.7

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.stream = load("res://assets/Music/3d20874f20174bd.mp3")
	
	# Загружаем сохранённую громкость
	load_music_volume()
	
	music_player.play()


# ============ УПРАВЛЕНИЕ ГРОМКОСТЬЮ ============

func set_music_volume(value: float) -> void:
	music_volume = clamp(value, 0.0, 1.0)
	var db_value = linear_to_db(music_volume)
	music_player.volume_db = db_value  # 👈 ТОЛЬКО volume_db, без шин
	save_music_volume()


func get_music_volume() -> float:
	return music_volume

# ============ УПРАВЛЕНИЕ ПЛЕЕРОМ ============

func stop_music() -> void:
	if music_player and music_player.playing:
		music_player.stop()


func start_music() -> void:
	if music_player and not music_player.playing:
		music_player.play()
	

func fade_out_music(duration: float = 0.5) -> void:
	if music_player and music_player.playing:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, duration)
		await tween.finished
		music_player.stop()
		music_player.volume_db = linear_to_db(music_volume)  # Восстанавливаем
	

# ============ СОХРАНЕНИЕ ============

func save_music_volume() -> void:
	var data = {"music_volume": music_volume}
	var file = FileAccess.open("user://music_settings.save", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
	

func load_music_volume() -> void:
	if FileAccess.file_exists("user://music_settings.save"):
		var file = FileAccess.open("user://music_settings.save", FileAccess.READ)
		var json_str = file.get_as_text()
		var json = JSON.new()
		
		if json.parse(json_str) == OK:
			var data = json.data
			music_volume = data.get("music_volume", 0.7)
			set_music_volume(music_volume)  # 👈 Применяем громкость

	else:
		set_music_volume(0.7)
