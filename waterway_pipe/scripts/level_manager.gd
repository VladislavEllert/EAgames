extends Node

signal level_changed(level_num: int)
signal all_levels_complete()

## Теперь уровни — это пути к сценам
var levels: Array[String] = [
	"res://scenes/levels/level_1.tscn",
	"res://scenes/levels/level_2.tscn",
	"res://scenes/levels/level_3.tscn"
	# Добавляйте сюда новые уровни по мере создания
]

var current_level: int = 0
var completed_levels: Array[int] = []
var best_times: Dictionary = {}
var best_moves: Dictionary = {}

func _ready() -> void:
	_load_progress()

func _load_progress() -> void:
	if FileAccess.file_exists("user://progress.save"):
		var file = FileAccess.open("user://progress.save", FileAccess.READ)
		var json_str = file.get_as_text()
		var json = JSON.new()
		if json.parse(json_str) == OK:
			var data = json.data
			if data is Dictionary:
				current_level = data.get("current_level", 0)
				completed_levels = data.get("completed_levels", [])
				best_times = data.get("best_times", {})
				best_moves = data.get("best_moves", {})

func save_progress() -> void:
	var data = {
		"current_level": current_level,
		"completed_levels": completed_levels,
		"best_times": best_times,
		"best_moves": best_moves
	}
	var file = FileAccess.open("user://progress.save", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))

func complete_level(time: float, moves: int) -> void:
	if current_level not in completed_levels:
		completed_levels.append(current_level)
	
	if not best_times.has(current_level) or time < best_times[current_level]:
		best_times[current_level] = time
	if not best_moves.has(current_level) or moves < best_moves[current_level]:
		best_moves[current_level] = moves
	
	save_progress()
	
	if current_level < levels.size() - 1:
		current_level += 1
		level_changed.emit(current_level)
	else:
		all_levels_complete.emit()

## ✅ ЭТА ФУНКЦИЯ ТЕПЕРЬ ЕСТЬ
func get_current_level_path() -> String:
	return levels[current_level]

func go_to_level(level_num: int) -> void:
	current_level = level_num
	level_changed.emit(current_level)

func is_level_unlocked(level_num: int) -> bool:
	return level_num == 0 or (level_num - 1) in completed_levels

func get_stars(level_num: int) -> int:
	if level_num not in completed_levels:
		return 0
	
	var stars = 1
	var moves = best_moves.get(level_num, 999)
	var time = best_times.get(level_num, 999.0)
	
	if moves <= 10:
		stars += 1
	if time <= 30:
		stars += 1
	
	return min(stars, 3)
