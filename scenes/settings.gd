extends Panel

@onready var reset_button: Button = $ResetButton

func _ready() -> void:
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)

func _on_reset_pressed() -> void:
	SoundManager.play_button_click()
	LevelManager.reset_progress()


func _on_button_2_pressed() -> void:
	SoundManager.play_button_click()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
