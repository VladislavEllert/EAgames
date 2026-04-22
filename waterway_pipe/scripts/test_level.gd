extends Node2D

@onready var grid_container = $GridContainer

func _ready() -> void:
	print("=== ТЕСТОВАЯ ДИАГНОСТИКА ===")
	
	if grid_container == null:
		print("❌ GridContainer не найден!")
		return
	else:
		print("✅ GridContainer найден")
	
	var children = grid_container.get_children()
	print("Детей в GridContainer: ", children.size())
	
	for i in range(children.size()):
		var child = children[i]
		print("\n--- Ребёнок ", i, ": ", child.name, " ---")
		print("  Тип узла: ", child.get_class())
		
		# Проверяем методы
		print("  Есть rotate_pipe? ", child.has_method("rotate_pipe"))
		print("  Есть fill_with_water? ", child.has_method("fill_with_water"))
		print("  Есть get_active_sides? ", child.has_method("get_active_sides"))
		
		# Проверяем свойства
		if child.has_method("get"):
			print("  pipe_type: ", child.get("pipe_type") if child.has_method("get") else "нет")
		
		# Проверяем grid_position
		if "grid_position" in child:
			print("  grid_position: ", child.grid_position)
		else:
			print("  ❌ НЕТ СВОЙСТВА grid_position!")
