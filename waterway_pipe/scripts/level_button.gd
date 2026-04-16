extends Button

signal level_selected(level_num: int)

@export var level_num: int = 0
@export var is_locked: bool = false  # Игнорируется
@export var stars: int = 0

@onready var label: Label = $Label
@onready var stars_container: HBoxContainer = $Stars
@onready var lock_icon: TextureRect = $LockIcon

var star_yellow = preload("res://assets/sprites/star_yellow.png")
var star_gray = preload("res://assets/sprites/star_gray.png")

func _ready() -> void:
	label.text = str(level_num + 1)
	
	# ✅ Кнопки всегда активны
	disabled = false
	modulate = Color.WHITE
	lock_icon.visible = false
	
	_update_stars()
	pressed.connect(_on_pressed)

func _update_stars() -> void:
	for child in stars_container.get_children():
		child.queue_free()
	
	var star = Sprite2D.new()
	if stars > 0:
		star.texture = star_yellow
	else:
		star.texture = star_gray
	
	star.scale = Vector2(0.6, 0.6)
	stars_container.add_child(star)

func _on_pressed() -> void:
	level_selected.emit(level_num)
