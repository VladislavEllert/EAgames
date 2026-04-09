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

var level: Level
var is_paused: bool = false

## Спрайты звёзд
var star_yellow = preload("res://assets/sprites/star_yellow.png")
var star_gray = preload("res://assets/sprites/star_gray.png")

func _ready() -> void:
	complete_panel.visible = false
	pause_panel.visible = false
	level_manager.level_changed.connect(_on_level_changed)
	
	# Безопасное подключение кнопок
	_connect_button_safe($UI/CompletePanel/Buttons/NextButton, _on_next_button_pressed)
	_connect_button_safe($UI/CompletePanel/Buttons/MenuButton, _on_menu_button_pressed)
	_connect_button_safe($UI/PausePanel/Buttons/ResumeButton, _on_resume_button_pressed)
	_connect_button_safe($UI/PausePanel/Buttons/RestartButton, _on_restart_button_pressed)
	
	_load_level(level_manager.current_level)

func _connect_button_safe(btn: Button, callback: Callable) -> void:
	if btn:
		if not btn.pressed.is_connected(callback):
			btn.pressed.connect(callback)
	else:
		push_warning("Кнопка не найдена! Проверьте структуру сцены.")

func _load_level(level_num: int) -> void:
	if level:
		level.queue_free()
	
	var level_scene = load(level_manager.get_current_level_path())
	level = level_scene.instantiate()
	level.name = "Level"
	add_child(level)
	move_child(level, 0)
	
	level.level_complete.connect(_on_level_complete)
	level.update_timer.connect(_on_update_timer)
	level.update_moves.connect(_on_update_moves)
	
	level_label.text = "Уровень %d" % (level_num + 1)
	complete_panel.visible = false
	_set_pause(false)

func _set_pause(paused: bool) -> void:
	is_paused = paused
	get_tree().paused = paused
	pause_panel.visible = paused
	pause_button.disabled = paused

func _on_pause_button_pressed() -> void:
	if level and level.is_completed:
		return
	_set_pause(true)

func _on_resume_button_pressed() -> void:
	_set_pause(false)

func _on_restart_button_pressed() -> void:
	if level:
		level.reset_level()
	complete_panel.visible = false
	_set_pause(false)

func _on_menu_button_pressed() -> void:
	_set_pause(false)
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_level_complete(success: bool, time: float, moves: int) -> void:
	if success:
		complete_panel.visible = true
		complete_time.text = "Время: %.1f сек" % time
		complete_moves.text = "Ходы: %d" % moves
		
		# Очищаем старые звёзды
		for child in stars_container.get_children():
			child.queue_free()
		
		# ✅ ОДНА ЖЁЛТАЯ ЗВЕЗДА ЗА ПРОХОЖДЕНИЕ
		var star = Sprite2D.new()
		star.texture = star_yellow
		star.scale = Vector2(1.0, 1.0)  # Размер звезды
		stars_container.add_child(star)

func _on_update_timer(seconds: int) -> void:
	# ✅ Исправлено: целочисленное деление //
	timer_label.text = "%02d:%02d" % [seconds / 60, seconds % 60]

func _on_update_moves(count: int) -> void:
	moves_label.text = "Ходы: %d" % count

func _on_next_button_pressed() -> void:
	if level:
		level_manager.complete_level(level.elapsed_time, level.move_count)

func _on_level_changed(_level_num: int) -> void:
	pass
