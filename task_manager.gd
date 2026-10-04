# autoload/task_manager.gd
# Afegeix-lo a Project > Project Settings > Autoload
# Nom: TaskManager
extends Node

signal task_changed(new_id: String)

@export_file("*.csv") var csv_path: String = "res://tasks.txt"

var current_task_id: String = "TASK_001"
var _tasks: Dictionary = {}  # "TASK_001" -> { "en": "...", "es": "..." }
var _id_column_index: int = -1
var _lang_columns: Dictionary = {}  # "en" -> índex columna
var in_dialogue: bool = false # false = fora de diàleg, true = en diàleg

func _ready() -> void:
	_load_tasks_from_csv()

# ─── API pública ────────────────────────────────────────────────────────────

## Canvia la tasca actual des de qualsevol script:
## TaskManager.set_task("TASK_004")
func set_task(id: String) -> void:
	id = id.strip_edges()
	if not _tasks.has(id):
		push_warning("TaskManager: id desconegut '%s'" % id)
		return
	current_task_id = id
	task_changed.emit(id)

## Retorna el text de la tasca actual per a un idioma donat
func get_task_text(lang_code: String = "en") -> String:
	return get_text_for(current_task_id, lang_code)

## Retorna el text d'una tasca concreta per a un idioma donat
func get_text_for(id: String, lang_code: String = "en") -> String:
	if not _tasks.has(id):
		return "MISSING: %s" % id
	var langs: Dictionary = _tasks[id]
	if langs.has(lang_code):
		return langs[lang_code]
	if langs.has("en"):
		return langs["en"]
	return "MISSING_LANG: %s (%s)" % [id, lang_code]

# ─── Càrrega CSV ────────────────────────────────────────────────────────────

func _parse_line(line: String) -> PackedStringArray:
	if line.find("\t") != -1:
		return line.split("\t", false)
	return line.split(",", false)

func _load_tasks_from_csv() -> void:
	var file := FileAccess.open(csv_path, FileAccess.READ)
	if file == null:
		push_error("TaskManager: no s'ha pogut obrir '%s'" % csv_path)
		return

	var header: PackedStringArray = []
	while file.get_position() < file.get_length():
		var raw := file.get_line()
		if raw.strip_edges() == "":
			continue
		var row := _parse_line(raw)
		if row.size() == 0:
			continue

		# Capçalera
		if header.is_empty():
			header = row
			for i in header.size():
				header[i] = header[i].strip_edges()
			_id_column_index = header.find("id")
			if _id_column_index == -1:
				push_error("TaskManager: el CSV necessita columna 'id'")
				return
			_lang_columns.clear()
			for i in header.size():
				var h := header[i]
				if h == "" or h == "id":
					continue
				_lang_columns[h] = i
			continue

		# Files de dades
		if _id_column_index < 0 or _id_column_index >= row.size():
			continue
		var id := row[_id_column_index].strip_edges()
		if id == "":
			continue
		var langs := {}
		for lang in _lang_columns.keys():
			var col: int = _lang_columns[lang]
			if col < row.size():
				langs[lang] = row[col].strip_edges()
		_tasks[id] = langs
