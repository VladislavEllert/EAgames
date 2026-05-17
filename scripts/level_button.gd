extends Button

signal level_selected(level_num: int)

@export var level_num: int = 0:
	set(value):
		level_num = value
		# Автоматически обновляем текст, как только значение меняется
		if label:
			label.text = str(level_num + 1)
@export var is_locked: bool = false  
@export var stars: int = 0

@onready var label: Label = $Label
@onready var stars_container: HBoxContainer = $Stars
@onready var lock_icon: TextureRect = $LockIcon

var star_yellow = preload("res://assets/sprites/star_yellow.png")
var star_gray = preload("res://assets/sprites/star_gray.png")

func _ready() -> void:
	label.text = str(level_num + 1)
	
	# Оставляем визуальную блокировку, но НЕ отключаем кнопку полностью
	disabled = false  # Важно! Иначе pressed не сработает
	lock_icon.visible = is_locked
	modulate = Color(1, 1, 1, 0.5 if is_locked else 1.0)
	
	_update_stars()
	pressed.connect(_on_pressed)

func _update_stars() -> void:
	for child in stars_container.get_children():
		child.queue_free()
	
	var star = Sprite2D.new()
	star.texture = star_yellow if stars > 0 else star_gray
	star.scale = Vector2(0.6, 0.6)
	stars_container.add_child(star)

func _on_pressed() -> void:
	# Всегда эмитим сигнал, а menu.gd сам решит, что делать
	level_selected.emit(level_num)
