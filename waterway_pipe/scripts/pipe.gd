@tool
class_name Pipe extends Area2D

enum PipeType {
	EMPTY, STRAIGHT, CORNER, CROSS, T_JUNCTION, START, END
}

enum Side { TOP = 0, RIGHT = 1, BOTTOM = 2, LEFT = 3 }

@export var pipe_type: PipeType = PipeType.STRAIGHT:
	set(value):
		pipe_type = value
		_update_visuals()

@export var is_locked: bool = false:
	set(value):
		is_locked = value
		_update_visuals()

@export var is_filled: bool = false:
	set(value):
		is_filled = value
		_update_visuals()

@export var grid_position: Vector2i = Vector2i.ZERO

@onready var sprite: Sprite2D = $Sprite2D
@onready var water_sprite: Sprite2D = $WaterSprite2D
@onready var touch_area: Area2D = $TouchArea2D

var rotation_state: int = 0

signal pipe_rotated(pipe: Pipe)

func _ready() -> void:
	_update_visuals()
	# Инициализируем позицию при старте
	_update_grid_from_index()
	
	if not Engine.is_editor_hint():
		if touch_area:
			touch_area.input_event.connect(_on_input_event)

## Обработка изменений в редакторе и в игре
func _notification(what: int) -> void:
	# Срабатывает, когда узел добавляется, перемещается в дереве или сцена пересортировывается
	if what == NOTIFICATION_ENTER_TREE or what == NOTIFICATION_MOVED_IN_PARENT:
		_update_grid_from_index()

func _update_grid_from_index() -> void:
	var parent = get_parent()
	if parent is GridContainer:
		var columns = parent.columns
		if columns > 0:
			var idx = get_index()
			var gx = idx % columns
			var gy = idx / columns
			
			if grid_position != Vector2i(gx, gy):
				grid_position = Vector2i(gx, gy)
				# В редакторе обновляем имя для наглядности
				if Engine.is_editor_hint():
					name = "Pipe_%d_%d" % [gx, gy]

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
		PipeType.START: base = [Side.BOTTOM]
		PipeType.END: base = [Side.TOP]
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
	if water_sprite:
		water_sprite.visible = true
		water_sprite.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(water_sprite, "modulate:a", 1.0, 0.3)

func reset_fill() -> void:
	is_filled = false
	if water_sprite:
		water_sprite.visible = false

func _update_visuals() -> void:
	if not is_inside_tree(): return
	if sprite == null: sprite = get_node_or_null("Sprite2D")
	if sprite == null: return
	
	var type_name: String = ""
	match pipe_type:
		PipeType.STRAIGHT: type_name = "straight"
		PipeType.CORNER: type_name = "corner"
		PipeType.CROSS: type_name = "cross"
		PipeType.T_JUNCTION: type_name = "t"
		PipeType.START: type_name = "start"
		PipeType.END: type_name = "end"
		_:
			sprite.texture = null
			return
	
	var tex_path: String = "res://assets/sprites/pipe_%s.png" % type_name
	
	if FileAccess.file_exists(tex_path):
		sprite.texture = load(tex_path)
		sprite.modulate = Color.WHITE
	else:
		# Фолбэк, если текстуры нет
		match pipe_type:
			PipeType.START: sprite.modulate = Color(0.2, 0.8, 0.3)
			PipeType.END: sprite.modulate = Color(0.8, 0.3, 0.2)
			_: sprite.modulate = Color(0.6, 0.7, 0.8)
	
	if water_sprite:
		water_sprite.visible = is_filled
	
	if is_locked and pipe_type not in [PipeType.START, PipeType.END]:
		sprite.modulate = sprite.modulate * Color(0.5, 0.5, 0.5)
