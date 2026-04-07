extends Node

@onready var ui: CanvasLayer = $UI
@onready var level_label: Label = $UI/TopBar/LevelLabel
@onready var timer_label: Label = $UI/TopBar/TimerLabel
@onready var moves_label: Label = $UI/TopBar/MovesLabel
@onready var complete_panel: ColorRect = $UI/CompletePanel
@onready var complete_time: Label = $UI/CompletePanel/TimeLabel
@onready var complete_moves: Label = $UI/CompletePanel/MovesLabel
@onready var stars_container: HBoxContainer = $UI/CompletePanel/Stars
@onready var level_manager: Node = $LevelManager

var level: Level

func _ready() -> void:
	complete_panel.visible = false
	level_manager.level_changed.connect(_on_level_changed)
	_load_level(level_manager.current_level)

func _on_level_changed(level_num: int) -> void:
	_load_level(level_num)

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

func _on_level_complete(success: bool, time: float, moves: int) -> void:
	if success:
		complete_panel.visible = true
		complete_time.text = "Время: %.1f сек" % time
		complete_moves.text = "Ходы: %d" % moves
		
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
	timer_label.text = "%02d:%02d" % [seconds / 60, seconds % 60]

func _on_update_moves(count: int) -> void:
	moves_label.text = "Ходы: %d" % count

func _on_next_button_pressed() -> void:
	level_manager.complete_level(level.elapsed_time, level.move_count)

func _on_restart_button_pressed() -> void:
	level.reset_level()
	complete_panel.visible = false

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
