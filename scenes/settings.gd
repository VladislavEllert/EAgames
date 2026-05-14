extends Panel

@onready var sfx_slider: HSlider = $SFXSlider
@onready var sfx_percent: Label = $SFXPercent
@onready var music_slider: HSlider = $MusicSlider
@onready var music_percent: Label = $MusicPercent
@onready var reset_button: Button = $ResetButton
@onready var back_button: Button = $Button2

func _ready() -> void:

	# Настройка ползунка звуков
	if sfx_slider:
		sfx_slider.min_value = 0.0
		sfx_slider.max_value = 1.0
		sfx_slider.step = 0.01
		sfx_slider.value = SoundManager.sfx_volume
		sfx_slider.value_changed.connect(_on_sfx_volume_changed)
		_update_sfx_percent()
	
	# Настройка ползунка музыки
	if music_slider:
		music_slider.min_value = 0.0
		music_slider.max_value = 1.0
		music_slider.step = 0.01
		music_slider.value = MusicManager.music_volume
		music_slider.value_changed.connect(_on_music_volume_changed)
		_update_music_percent()
	
	# Кнопки
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)
	
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

func _on_sfx_volume_changed(value: float) -> void:
	SoundManager.set_sfx_volume(value)
	_update_sfx_percent()

func _on_music_volume_changed(value: float) -> void:
	MusicManager.set_music_volume(value)
	_update_music_percent()

func _update_sfx_percent() -> void:
	if sfx_slider and sfx_percent:
		var percent = int(sfx_slider.value * 100)
		sfx_percent.text = str(percent) + "%"

func _update_music_percent() -> void:
	if music_slider and music_percent:
		var percent = int(music_slider.value * 100)
		music_percent.text = str(percent) + "%"

func _on_reset_pressed() -> void:
	SoundManager.play_button_click()
	LevelManager.reset_progress()

func _on_back_pressed() -> void:
	SoundManager.play_button_click()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
