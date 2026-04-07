extends Control

@onready var main_panel: Panel = $MainPanel
@onready var level_select_panel: Panel = $LevelSelectPanel
@onready var levels_container: GridContainer = $LevelSelectPanel/Scroll/Levels
@onready var level_manager: Node = $LevelManager

var level_button_scene = preload("../scenes/level_button.tscn")

func _ready() -> void:
	# Подключаем сигналы
	level_manager.level_changed.connect(_on_level_changed)
	
	# Инициализируем меню
	_setup_main_panel()
	_create_level_buttons()
	
	# Показываем главный экран
	_show_main_panel()

func _setup_main_panel() -> void:
	# Анимация заголовка
	var title = $MainPanel/Title
	title.modulate.a = 0.0
	title.position.y -= 30
	
	var tween = create_tween()
	tween.tween_property(title, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(title, "position:y", title.position.y + 30, 0.5).set_ease(Tween.EASE_OUT)

func _create_level_buttons() -> void:
	# Очищаем старые кнопки
	for child in levels_container.get_children():
		child.queue_free()
	
	# Создаём кнопки для каждого уровня
	for i in level_manager.levels.size():
		var btn = level_button_scene.instantiate()
		btn.level_num = i
		btn.is_locked = not level_manager.is_level_unlocked(i)
		btn.stars = level_manager.get_stars(i)
		
		btn.level_selected.connect(_on_level_selected)
		levels_container.add_child(btn)

func _show_main_panel() -> void:
	# Явно разрешаем клики на главной панели
	main_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	main_panel.modulate.a = 1.0
	main_panel.position.y = 0
	
	# Блокируем клики на панели уровней и скрываем её
	level_select_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	level_select_panel.modulate.a = 0.0
	
	# Анимация (опционально)
	var tween = create_tween()
	tween.tween_property(level_select_panel, "modulate:a", 0.0, 0.3)
	tween.tween_property(main_panel, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(main_panel, "position:y", 0, 0.3).set_ease(Tween.EASE_OUT)

func _show_level_select() -> void:
	# Блокируем клики на главной панели
	main_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_panel.modulate.a = 0.0
	
	# Разрешаем клики на панели уровней
	level_select_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	level_select_panel.modulate.a = 1.0
	level_select_panel.position.y = 0
	
	# Анимация
	var tween = create_tween()
	tween.tween_property(main_panel, "modulate:a", 0.0, 0.3)
	tween.tween_property(level_select_panel, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(level_select_panel, "position:y", 0, 0.3).set_ease(Tween.EASE_OUT)

## Обработчики кнопок
func _on_play_button_pressed() -> void:
	_show_level_select()

func _on_back_button_pressed() -> void:
	_show_main_panel()

func _on_level_selected(level_num: int) -> void:
	level_manager.go_to_level(level_num)
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_level_changed(_level_num: int) -> void:
	# Обновляем кнопки при изменении прогресса
	_create_level_buttons()
