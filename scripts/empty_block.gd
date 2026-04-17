@tool
extends Sprite2D

## Размер клетки (должен совпадать с level.gd)
@export var cell_size: int = 100

func _ready() -> void:
	_snap_to_grid()

## Авто-выравнивание при перемещении в редакторе
func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		_snap_to_grid()

func _snap_to_grid() -> void:
	if not Engine.is_editor_hint():
		return
	
	# Округляем позицию до ближайшей клетки
	var gx = roundi(position.x / cell_size)
	var gy = roundi(position.y / cell_size)
	position = Vector2(gx, gy) * cell_size
