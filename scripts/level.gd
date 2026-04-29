class_name Level extends Node2D

signal level_complete(success: bool, time: float, moves: int)
signal update_timer(seconds: int)
signal update_moves(count: int)

@export var grid_size: Vector2i = Vector2i(6, 8)
@export var cell_size: int = 100

@onready var grid_container: Node2D = $GridContainer

var pipes: Dictionary = {}
var start_pipe: Pipe = null
var end_pipe: Pipe = null

var elapsed_time: float = 0.0
var move_count: int = 0
var is_playing: bool = false
var is_completed: bool = false

func _ready() -> void:
	_scan_pipes()
	await reset_level()

func _process(delta: float) -> void:
	if is_playing and not is_completed:
		elapsed_time += delta
		if int(elapsed_time) != int(elapsed_time - delta):
			update_timer.emit(int(elapsed_time))

func _scan_pipes() -> void:
	pipes.clear()
	start_pipe = null
	end_pipe = null
	
	if grid_container == null:
		push_error("GridContainer не найден!")
		return
	
	for child in grid_container.get_children():
		if child is Pipe:
			var pipe: Pipe = child
			var pos = pipe.grid_position
			pipes[pos] = pipe
			
			if not pipe.pipe_rotated.is_connected(_on_pipe_rotated):
				pipe.pipe_rotated.connect(_on_pipe_rotated)
			
			if pipe.pipe_type == Pipe.PipeType.START:
				start_pipe = pipe
			elif pipe.pipe_type == Pipe.PipeType.END:
				end_pipe = pipe

func reset_level() -> void:
	var attempts = 0
	var max_attempts = 50
	
	while attempts < max_attempts:
		_randomize_pipes()
		
		if not await _check_connections(true):
			break
		
		attempts += 1
	
	if attempts >= max_attempts:
		push_warning("⚠️ Не удалось сгенерировать нерешённый уровень за %d попыток. Принудительный поворот." % max_attempts)
		_force_break_solution()
	
	for pipe in pipes.values():
		pipe.reset_fill()
	
	elapsed_time = 0.0
	move_count = 0
	is_completed = false
	is_playing = true
	update_moves.emit(0)
	
	await _check_connections(false)

## Перемешивание труб
func _randomize_pipes() -> void:
	for pipe in pipes.values():
		if not pipe.is_locked and pipe.pipe_type not in [Pipe.PipeType.START, Pipe.PipeType.END]:
			pipe.rotation_state = randi() % 4
			pipe.rotation_degrees = pipe.rotation_state * 90
			pipe._update_visuals()

## Принудительно ломает решение, поворачивая одну трубу
func _force_break_solution() -> void:
	for pipe in pipes.values():
		if not pipe.is_locked and pipe.pipe_type not in [Pipe.PipeType.START, Pipe.PipeType.END]:
			pipe.rotate_pipe()
			return

func _on_pipe_rotated(_pipe: Pipe) -> void:
	if is_completed:
		return
	move_count += 1
	update_moves.emit(move_count)
	
	await _check_connections(false)

func _check_connections(dry_run: bool = false) -> bool:
	if start_pipe == null or end_pipe == null:
		return false
	
	if not dry_run:
		for pipe in pipes.values():
			pipe.reset_fill()
	
	var visited: Dictionary = {}
	var queue: Array = [start_pipe]
	visited[start_pipe.grid_position] = true
	
	if not dry_run:
		start_pipe.fill_with_water()
	
	var reached_end: bool = false
	
	while queue.size() > 0:
		var current: Pipe = queue.pop_front()
		
		if current == end_pipe:
			reached_end = true
			if dry_run:
				pass
		
		for side in current.get_active_sides():
			var neighbor_pos = _get_neighbor_pos(current.grid_position, side)
			
			if not pipes.has(neighbor_pos) or visited.has(neighbor_pos):
				continue
			
			var neighbor: Pipe = pipes[neighbor_pos]
			var opposite = Pipe.get_opposite_side(side)
			
			if current.has_connection_to(side) and neighbor.has_connection_to(opposite):
				visited[neighbor_pos] = true
				
				if not dry_run:
					neighbor.fill_with_water()
				
				queue.append(neighbor)
	
	var all_pipes_closed: bool = _check_all_pipes_closed()
	
	var is_solved: bool = reached_end and all_pipes_closed
	
	# Отладка
	if reached_end and not all_pipes_closed:
		if not dry_run:
			print("⚠️ Путь собран, но есть незакрытые соединения! Уровень не завершён.")
	
	if not dry_run and is_solved and not is_completed:
		is_completed = true
		is_playing = false
		await get_tree().create_timer(1.0).timeout
		level_complete.emit(true, elapsed_time, move_count)
	
	return is_solved

## Проверка закрытости всех труб
func _check_all_pipes_closed() -> bool:
	for pipe in pipes.values():
		for side in pipe.get_active_sides():
			var neighbor_pos = _get_neighbor_pos(pipe.grid_position, side)
			
			if not pipes.has(neighbor_pos):
				return false
			
			var neighbor: Pipe = pipes[neighbor_pos]
			var opposite = Pipe.get_opposite_side(side)
			
			if not neighbor.has_connection_to(opposite):
				return false
	
	return true

func _get_neighbor_pos(pos: Vector2i, side: int) -> Vector2i:
	match side:
		Pipe.Side.TOP: return pos + Vector2i(0, -1)
		Pipe.Side.RIGHT: return pos + Vector2i(1, 0)
		Pipe.Side.BOTTOM: return pos + Vector2i(0, 1)
		Pipe.Side.LEFT: return pos + Vector2i(-1, 0)
	return pos

func get_cell_size() -> int:
	return cell_size
