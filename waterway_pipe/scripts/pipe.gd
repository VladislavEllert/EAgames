@tool
class_name Pipe extends Area2D

## Типы труб
enum PipeType {
	EMPTY,
	STRAIGHT,
	CORNER,
	CROSS,
	T_JUNCTION,
	START,
	END
}

enum Side { TOP = 0, RIGHT = 1, BOTTOM = 2, LEFT = 3 }

## Настройки
@export var pipe_type: PipeType = PipeType.STRAIGHT:
	set(value):
		pipe_type = value
		_update_visuals()

@export var is_locked: bool = false:
	set(value):
		is_locked = value
		_update_visuals()

@export var grid_position: Vector2i = Vector2i.ZERO

## Ссылки
@onready var sprite: Sprite2D = $Sprite2D
@onready var water_sprite: Sprite2D = $WaterSprite2D
@onready var touch_area: Area2D = $TouchArea2D

## Состояние
var rotation_state: int = 0
var is_filled: bool = false

signal pipe_rotated(pipe: Pipe)

func _ready() -> void:
	_update_visuals()
	if not Engine.is_editor_hint():
		touch_area.input_event.connect(_on_input_event)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		rotate_pipe()

func rotate_pipe() -> void:
	if is_locked or pipe_type in [PipeType.EMPTY, PipeType.START, PipeType.END]:
		return
	rotation_state = (rotation_state + 1) % 4
	rotation_degrees = rotation_state * 90
	pipe_rotated.emit(self)

func get_active_sides() -> Array[int]:
	var base: Array[int] = []
	match pipe_type:
		PipeType.STRAIGHT: base = [Side.TOP, Side.BOTTOM]
		PipeType.CORNER: base = [Side.TOP, Side.RIGHT]
		PipeType.CROSS: base = [Side.TOP, Side.RIGHT, Side.BOTTOM, Side.LEFT]
		PipeType.T_JUNCTION: base = [Side.TOP, Side.RIGHT, Side.BOTTOM]
		PipeType.START, PipeType.END: base = [Side.BOTTOM]
		_: return []
	
	var result: Array[int] = []
	for side in base:
		result.append((side + rotation_state) % 4)
	return result

func has_connection_to(side: int) -> bool:
	return side in get_active_sides()

static func get_opposite_side(side: int) -> int:
	return (side + 2) % 4

func fill_with_water() -> void:
	if is_filled:
		return
	is_filled = true
	water_sprite.visible = true
	water_sprite.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(water_sprite, "modulate:a", 1.0, 0.3)

func reset_fill() -> void:
	is_filled = false
	water_sprite.visible = false

func _update_visuals() -> void:
	if sprite == null:
		return
	
	var tex_path = ""
	match pipe_type:
		PipeType.STRAIGHT: tex_path = "res://assets/sprites/pipe_straight.png"
		PipeType.CORNER: tex_path = "res://assets/sprites/pipe_corner.png"
		PipeType.CROSS: tex_path = "res://assets/sprites/pipe_cross.png"
		PipeType.T_JUNCTION: tex_path = "res://assets/sprites/pipe_t.png"
		PipeType.START: tex_path = "res://assets/sprites/pipe_start.png"
		PipeType.END: tex_path = "res://assets/sprites/pipe_end.png"
	
	if tex_path != "" and FileAccess.file_exists(tex_path):
		sprite.texture = load(tex_path)
		sprite.modulate = Color.WHITE
	else:
		sprite.texture = null
		match pipe_type:
			PipeType.START: sprite.modulate = Color(0.2, 0.8, 0.3)
			PipeType.END: sprite.modulate = Color(0.8, 0.3, 0.2)
			_: sprite.modulate = Color(0.6, 0.7, 0.8)
	
	if is_locked and pipe_type not in [PipeType.START, PipeType.END]:
		sprite.modulate = sprite.modulate * Color(0.7, 0.7, 0.7)
