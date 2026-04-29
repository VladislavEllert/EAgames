extends Node

@onready var ui: CanvasLayer = $UI
@onready var level_label: Label = $UI/TopBar/LevelLabel
@onready var timer_label: Label = $UI/TopBar/TimerLabel
@onready var moves_label: Label = $UI/TopBar/MovesLabel
@onready var complete_panel: ColorRect = $UI/CompletePanel
@onready var complete_time: Label = $UI/CompletePanel/TimeLabel
@onready var complete_moves: Label = $UI/CompletePanel/MovesLabel
@onready var stars_container: HBoxContainer = $UI/CompletePanel/Stars
@onready var pause_panel: ColorRect = $UI/PausePanel
@onready var pause_button: Button = $UI/TopBar/PauseButton

var current_level_instance: Node2D = null
var is_paused: bool = false

func _ready() -> void:
	complete_panel.visible = false
	pause_panel.visible = false
	
	if LevelManager.level_changed.is_connected(_on_level_changed):
		LevelManager.level_changed.disconnect(_on_level_changed)
	LevelManager.level_changed.connect(_on_level_changed)
	
	_connect_safe(pause_button, _on_pause_button_pressed)
	_connect_safe($UI/PausePanel/Buttons/ResumeButton, _on_resume_button_pressed)
	_connect_safe($UI/PausePanel/Buttons/RestartButton, _on_restart_button_pressed)
	_connect_safe($UI/PausePanel/Buttons/MenuButton, _on_menu_button_pressed)
	_connect_safe($UI/CompletePanel/Buttons/NextButton, _on_next_button_pressed)
	
	_load_level(LevelManager.current_level)

func _connect_safe(btn: Button, callback: Callable) -> void:
	if btn and not btn.pressed.is_connected(callback):
		btn.pressed.connect(callback)

func _load_level(level_num: int) -> void:
	if current_level_instance:
		current_level_instance.queue_free()
	
	var level_path = LevelManager.get_current_level_path()
	var level_scene = load(level_path)
	
	if level_scene == null:
		push_error("❌ Не удалось загрузить уровень: " + level_path)
		return
	
	current_level_instance = level_scene.instantiate()
	current_level_instance.name = "Level"
	
	if has_node("LevelContainer"):
		$LevelContainer.add_child(current_level_instance)
	else:
		add_child(current_level_instance)
		move_child(current_level_instance, 0)
	
	if current_level_instance.has_signal("level_complete"):
		if current_level_instance.level_complete.is_connected(_on_level_complete):
			current_level_instance.level_complete.disconnect(_on_level_complete)
		current_level_instance.level_complete.connect(_on_level_complete)
	
	if current_level_instance.has_signal("update_timer"):
		if current_level_instance.update_timer.is_connected(_on_update_timer):
			current_level_instance.update_timer.disconnect(_on_update_timer)
		current_level_instance.update_timer.connect(_on_update_timer)
	
	if current_level_instance.has_signal("update_moves"):
		if current_level_instance.update_moves.is_connected(_on_update_moves):
			current_level_instance.update_moves.disconnect(_on_update_moves)
		current_level_instance.update_moves.connect(_on_update_moves)
	
	level_label.text = "УРОВЕНЬ %d" % (level_num + 1)
	complete_panel.visible = false
	_set_pause(false)

func _set_pause(paused: bool) -> void:
	is_paused = paused
	get_tree().paused = paused
	pause_panel.visible = paused
	pause_button.disabled = paused

func _on_pause_button_pressed() -> void:
	if current_level_instance and current_level_instance.get("is_completed"):
		return
	_set_pause(true)

func _on_resume_button_pressed() -> void:
	_set_pause(false)

func _on_restart_button_pressed() -> void:
	if current_level_instance and current_level_instance.has_method("reset_level"):
		current_level_instance.reset_level()
	complete_panel.visible = false
	_set_pause(false)

func _on_menu_button_pressed() -> void:
	_set_pause(false)
	LevelManager.return_to_level_select = true
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_level_complete(success: bool, time: float, moves: int) -> void:
	if success:
		# Сохраняем прогресс сразу
		LevelManager.save_level_progress(time, moves)
		
		complete_panel.visible = true
		complete_time.text = "ВРЕМЯ: %.1f сек" % time
		complete_moves.text = "ХОДЫ: %d" % moves
		
		# Очищаем старые звёзды
		for child in stars_container.get_children():
			child.queue_free()
		
		# Создаём одну звезду
		var star = Sprite2D.new()
		star.texture = preload("res://assets/sprites/star_yellow.png")
		star.scale = Vector2(0, 0)  
		stars_container.add_child(star)
		
			sprite.modulate = Color(1, 1, 1) if i < stars else Color(0.3, 0.3, 0.3)
		var tween = create_tween()
		tween.tween_property(star, "scale", Vector2(1.0, 1.0), 0.4) \
			.set_trans(Tween.TRANS_BACK) \
			.set_ease(Tween.EASE_OUT)

func _on_update_timer(seconds: int) -> void:
	var minutes = seconds / 60
	var secs = seconds % 60
	timer_label.text = "%02d:%02d" % [minutes, secs]

func _on_update_moves(count: int) -> void:
	moves_label.text = "ХОДЫ: %d" % count

func _on_next_button_pressed() -> void:
	LevelManager.advance_level()

func _on_level_changed(_level_num: int) -> void:
	_load_level(_level_num)
