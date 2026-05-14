extends Node

# Звуковые плееры
var pipe_turn_sound: AudioStreamPlayer
var button_click_sound: AudioStreamPlayer
var level_complete_sound: AudioStreamPlayer

# Громкость звуков (0.0 - 1.0)
var sfx_volume: float = 0.8

func _ready() -> void:
	# Создаём плеер для поворота труб
	pipe_turn_sound = AudioStreamPlayer.new()
	add_child(pipe_turn_sound)
	pipe_turn_sound.stream = load("res://assets/Music/24f110d27ad0929.mp3")
	
	# Создаём плеер для кликов кнопок
	button_click_sound = AudioStreamPlayer.new()
	add_child(button_click_sound)
	button_click_sound.stream = load("res://assets/Music/quick short clicking sound on the button of an old typewriter.mp3")
	
	# Создаём плеер для завершения уровня
	level_complete_sound = AudioStreamPlayer.new()
	add_child(level_complete_sound)
	level_complete_sound.stream = load("res://assets/Music/The sound of victory in the game level.mp3")
	
	# Загружаем сохранённую громкость
	load_sfx_volume()

# ============ ОСНОВНЫЕ ФУНКЦИИ ДЛЯ ЗВУКОВ ============

func play_pipe_turn() -> void:
	if pipe_turn_sound:
		pipe_turn_sound.play()

func play_button_click() -> void:
	if button_click_sound:
		button_click_sound.play()

func play_level_complete() -> void:
	if level_complete_sound:
		level_complete_sound.play()

# ============ УПРАВЛЕНИЕ ГРОМКОСТЬЮ ============

func set_sfx_volume(value: float) -> void:
	sfx_volume = clamp(value, 0.0, 1.0)
	var db_value = linear_to_db(sfx_volume)
	
	if pipe_turn_sound:
		pipe_turn_sound.volume_db = db_value
	if button_click_sound:
		button_click_sound.volume_db = db_value
	if level_complete_sound:
		level_complete_sound.volume_db = db_value
	
	save_sfx_volume()

func save_sfx_volume() -> void:
	var data = {"sfx_volume": sfx_volume}
	var file = FileAccess.open("user://sfx_settings.save", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))

func load_sfx_volume() -> void:
	if FileAccess.file_exists("user://sfx_settings.save"):
		var file = FileAccess.open("user://sfx_settings.save", FileAccess.READ)
		var json_str = file.get_as_text()
		var json = JSON.new()
		
		if json.parse(json_str) == OK:
			var data = json.data
			sfx_volume = data.get("sfx_volume", 0.8)
			set_sfx_volume(sfx_volume)
