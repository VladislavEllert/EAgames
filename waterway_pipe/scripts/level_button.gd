extends Button

signal level_selected(level_num: int)

@export var level_num: int = 0
@export var is_locked: bool = false
@export var stars: int = 0

@onready var label: Label = $Label
@onready var stars_container: HBoxContainer = $Stars
@onready var lock_icon: TextureRect = $LockIcon

func _ready() -> void:
	label.text = str(level_num + 1)
	lock_icon.visible = is_locked
	disabled = is_locked
	
	# Звёзды
	for i in 3:
		var star = TextureRect.new()
		star.texture = preload("res://assets/sprites/star.png")
		star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		star.custom_minimum_size = Vector2(20, 20)
		star.modulate = Color(1, 1, 1) if i < stars else Color(0.3, 0.3, 0.3)
		stars_container.add_child(star)
	
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	level_selected.emit(level_num)
