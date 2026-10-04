extends Control

var tasks := {}  # "TASK_001" -> { "en": "...", "es": "..." }

func _ready():
	load_tasks_from_csv("res://data/tasks.csv")

func load_tasks_from_csv(path: String):
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("No se pudo abrir el CSV de tareas: %s" % path)
		return

	var header := []
	while file.get_position() < file.get_length():
		var row := file.get_csv_line()
		if row.size() == 0:
			continue

		if header.is_empty():
			header = row  # ["id","en","es"]
			continue

		var id := row[0]
		var en := row[1]
		var es := row[2]

		tasks[id] = {
			"en": en,
			"es": es,
		}
