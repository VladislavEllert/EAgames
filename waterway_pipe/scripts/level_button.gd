extends Button

signal level_selected(level_num: int)

@export var level_num: int = 0
@export var is_locked: bool = false
@export var stars: int = 0

@onready var label: Label = $Label
@onready var stars_container: HBoxContainer = $Stars
@onready var lock_icon: TextureRect = $LockIcon

var star_texture = preload("../assets/sprites/star.png")

func _ready() -> void:
	# Настройка текста
	label.text = str(level_num + 1)
	
	# Блокировка
	lock_icon.visible = is_locked
	disabled = is_locked
	
	if is_locked:
		modulate = Color(0.5, 0.5, 0.5)
	
	# Звёзды
	_update_stars()
	
	# Подключение сигнала
	pressed.connect(_on_pressed)

func _update_stars() -> void:
	for child in stars_container.get_children():
		child.queue_free()
	
	for i in 3:
		var star = TextureRect.new()
		star.texture = star_texture
		star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		star.custom_minimum_size = Vector2(24, 24)
		
		if i < stars:
			star.modulate = Color(1, 0.84, 0)  # Золотой
		else:
			star.modulate = Color(0.3, 0.3, 0.3)  # Серый
		
		stars_container.add_child(star)

func _on_pressed() -> void:
	level_selected.emit(level_num)
