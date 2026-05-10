@tool
extends Sprite2D

func _ready() -> void:
	if Engine.is_editor_hint():
		_snap_to_grid()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		if Engine.is_editor_hint():
			_snap_to_grid()

func _snap_to_grid() -> void:
	if not is_inside_tree():
		return
	
	var parent = get_parent()
	if not parent or not parent.has_method("get_cell_size"):
		return
	
	var cell_size = parent.get_cell_size()
	
	if cell_size <= 0:
		return
	
	# Вычисляем целевую позицию
	var gx = roundi(position.x / cell_size)
	var gy = roundi(position.y / cell_size)
	var target_pos = Vector2(gx, gy) * cell_size
	
	if not position.is_equal_approx(target_pos):
		position = target_pos
