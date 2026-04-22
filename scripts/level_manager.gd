extends Node

signal level_changed(level_num: int)
signal all_levels_complete()
signal progress_reset()

var levels: Array[String] = [
	"res://scenes/levels/level_1.tscn",
	"res://scenes/levels/level_2.tscn",
	"res://scenes/levels/level_3.tscn",
	"res://scenes/levels/level_4.tscn",
	"res://scenes/levels/level_5.tscn",
	"res://scenes/levels/level_6.tscn",
	"res://scenes/levels/level_7.tscn",
	"res://scenes/levels/level_8.tscn",
	"res://scenes/levels/level_9.tscn",
	"res://scenes/levels/level_10.tscn",
	"res://scenes/levels/level_11.tscn"
	
]

var current_level: int = 0
var completed_levels: Array[int] = []
var best_times: Dictionary = {}
var best_moves: Dictionary = {}
var return_to_level_select: bool = false

func _ready() -> void:
	_load_progress()

## ✅ Все уровни всегда доступны
func is_level_unlocked(_level_num: int) -> bool:
	return true

## ✅ 1 звезда = уровень пройден
func get_stars(level_num: int) -> int:
	return 1 if level_num in completed_levels else 0

func get_total_stars() -> int:
	return completed_levels.size()

func _load_progress() -> void:
	if FileAccess.file_exists("user://progress.save"):
		var file = FileAccess.open("user://progress.save", FileAccess.READ)
		var json_str = file.get_as_text()
		var json = JSON.new()
		
		if json.parse(json_str) == OK:
			var data = json.data
			if data is Dictionary:
				current_level = data.get("current_level", 0)
				
				var raw_completed = data.get("completed_levels", [])
				completed_levels.clear()
				if raw_completed is Array:
					for item in raw_completed:
						completed_levels.append(int(item))
				
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

func get_current_level_path() -> String:
	return levels[current_level]

func go_to_level(level_num: int) -> void:
	current_level = level_num
	level_changed.emit(current_level)

func reset_progress() -> void:
	current_level = 0
	completed_levels.clear()
	best_times.clear()
	best_moves.clear()
	
	if FileAccess.file_exists("user://progress.save"):
		DirAccess.remove_absolute("user://progress.save")
	
	save_progress()
	progress_reset.emit()
