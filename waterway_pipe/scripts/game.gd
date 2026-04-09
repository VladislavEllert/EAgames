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
@onready var level_manager: Node = $LevelManager

var current_level_instance: Node2D = null
var is_paused: bool = false

func _ready() -> void:
	complete_panel.visible = false
	pause_panel.visible = false
	
	level_manager.level_changed.connect(_on_level_changed)
	_load_level(level_manager.current_level)

func _load_level(level_num: int) -> void:
	# Удаляем старый уровень
	if current_level_instance:
		current_level_instance.queue_free()
	
	# Загружаем новый
	var level_path = level_manager.get_current_level_path()
	var level_scene = load(level_path)
	current_level_instance = level_scene.instantiate()
	current_level_instance.name = "Level"
	add_child(current_level_instance)
	move_child(current_level_instance, 0)
	
	# Подключаем сигналы
	if current_level_instance.has_signal("level_complete"):
		current_level_instance.level_complete.connect(_on_level_complete)
	if current_level_instance.has_signal("update_timer"):
		current_level_instance.update_timer.connect(_on_update_timer)
	if current_level_instance.has_signal("update_moves"):
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
	if current_level_instance and current_level_instance.has_method("is_completed") and current_level_instance.is_completed:
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
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_level_complete(success: bool, time: float, moves: int) -> void:
	if success:
		complete_panel.visible = true
		complete_time.text = "ВРЕМЯ: %.1f сек" % time
		complete_moves.text = "ХОДЫ: %d" % moves
		
		for child in stars_container.get_children():
			child.queue_free()
		
		var stars = level_manager.get_stars(level_manager.current_level)
		var star_tex = preload("res://assets/sprites/star.png")
		
		for i in 3:
			var sprite = Sprite2D.new()
			sprite.texture = star_tex
			sprite.scale = Vector2(0.5, 0.5)
			sprite.modulate = Color(1, 1, 1) if i < stars else Color(0.3, 0.3, 0.3)
			stars_container.add_child(sprite)

func _on_update_timer(seconds: int) -> void:
	var minutes = seconds / 60
	var secs = seconds % 60
	timer_label.text = "%02d:%02d" % [minutes, secs]

func _on_update_moves(count: int) -> void:
	moves_label.text = "ХОДЫ: %d" % count

func _on_next_button_pressed() -> void:
	if current_level_instance and current_level_instance.has_method("elapsed_time") and current_level_instance.has_method("move_count"):
		level_manager.complete_level(current_level_instance.elapsed_time, current_level_instance.move_count)

func _on_level_changed(_level_num: int) -> void:
	_load_level(_level_num)
