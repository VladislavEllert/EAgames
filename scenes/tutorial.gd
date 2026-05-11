extends Control

@onready var back_button: Button = $Panel/BackButton

func _ready() -> void:
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
