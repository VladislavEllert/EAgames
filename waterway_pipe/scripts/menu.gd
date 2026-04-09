extends Control

@onready var main_panel: Panel = $MainPanel
@onready var level_select_panel: Panel = $LevelSelectPanel
@onready var levels_container: GridContainer = $LevelSelectPanel/Scroll/Levels
@onready var total_stars_label: Label = $LevelSelectPanel/TotalStarsLabel
@onready var reset_button: Button = $LevelSelectPanel/ResetButton
@onready var level_manager: Node = $LevelManager

var level_button_scene = preload("res://scenes/level_button.tscn")

func _ready() -> void:
	level_manager.level_changed.connect(_on_level_changed)
	level_manager.progress_reset.connect(_on_progress_reset)
	
	reset_button.pressed.connect(_on_reset_button_pressed)
	
	_setup_main_panel()
	_create_level_buttons()
	_update_total_stars()
	_show_main_panel()

func _setup_main_panel() -> void:
	var title = $MainPanel/Title
	title.modulate.a = 0.0
	title.position.y -= 30
	
	var tween = create_tween()
	tween.tween_property(title, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(title, "position:y", title.position.y + 30, 0.5).set_ease(Tween.EASE_OUT)

func _create_level_buttons() -> void:
	for child in levels_container.get_children():
		child.queue_free()
	
	for i in level_manager.levels.size():
		var btn = level_button_scene.instantiate()
		btn.level_num = i
		btn.is_locked = false  # ✅ Уровни всегда доступны
		btn.stars = level_manager.get_stars(i)
		btn.level_selected.connect(_on_level_selected)
		levels_container.add_child(btn)

func _update_total_stars() -> void:
	if total_stars_label:
		total_stars_label.text = "Звёзды: %d / %d" % [level_manager.get_total_stars(), level_manager.levels.size()]

func _show_main_panel() -> void:
	main_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	main_panel.modulate.a = 1.0
	main_panel.position.y = 0
	
	level_select_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	level_select_panel.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(level_select_panel, "modulate:a", 0.0, 0.3)
	tween.tween_property(main_panel, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(main_panel, "position:y", 0, 0.3).set_ease(Tween.EASE_OUT)

func _show_level_select() -> void:
	main_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_panel.modulate.a = 0.0
	
	level_select_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	level_select_panel.modulate.a = 1.0
	level_select_panel.position.y = 0
	
	var tween = create_tween()
	tween.tween_property(main_panel, "modulate:a", 0.0, 0.3)
	tween.tween_property(level_select_panel, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(level_select_panel, "position:y", 0, 0.3).set_ease(Tween.EASE_OUT)

## Обработчики
func _on_play_button_pressed() -> void:
	_show_level_select()

func _on_back_button_pressed() -> void:
	_show_main_panel()

func _on_level_selected(level_num: int) -> void:
	level_manager.go_to_level(level_num)
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_level_changed(_level_num: int) -> void:
	_create_level_buttons()
	_update_total_stars()

## ✅ Сброс прогресса
func _on_reset_button_pressed() -> void:
	level_manager.reset_progress()

func _on_progress_reset() -> void:
	_create_level_buttons()
	_update_total_stars()
