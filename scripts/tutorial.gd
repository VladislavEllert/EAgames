extends Control

@onready var animated_pipe = $Panel/AnimatedPipe  # Sprite2D
@onready var back_button = $Panel/BackButton

func _ready() -> void:
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)
	
	# Если используешь TextureRect, раскомментируй:
	# animated_pipe.offset = animated_pipe.size / 2
	
	start_demo_animation()

func start_demo_animation() -> void:
	while true:
		await get_tree().create_timer(1.5).timeout
		
		# Поворачиваем на 90 градусов
		var tween = create_tween()
		tween.tween_property(animated_pipe, "rotation", 1.57, 0.1)
		await tween.finished
		
		await get_tree().create_timer(1.5).timeout
		
		# Возвращаем обратно
		tween = create_tween()
		tween.tween_property(animated_pipe, "rotation", 0, 0.1)
		await tween.finished

func _on_back_button_pressed() -> void:
	SoundManager.play_button_click()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
