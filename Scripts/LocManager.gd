extends Node

# Simple localization manager that reads from localization.csv
var current_lang = "ru" # default
var translations = {}

func _ready() -> void:
	load_translations()

func load_translations() -> void:
	if not FileAccess.file_exists("res://localization.csv"):
		printerr("localization.csv file not found!")
		return
		
	var file = FileAccess.open("res://localization.csv", FileAccess.READ)
	# Skip header line: KEY,ru,zh
	var _header = file.get_line().split(",")
	
	while not file.eof_reached():
		var line = file.get_line()
		if line.strip_edges() == "":
			continue
			
		# Split by comma but handle potential quotes
		var parts = _parse_csv_line(line)
		if parts.size() >= 3:
			var key = parts[0].strip_edges()
			var ru_text = parts[1].replace("\"", "").strip_edges()
			var zh_text = parts[2].replace("\"", "").strip_edges()
			translations[key] = {
				"ru": ru_text,
				"zh": zh_text
			}
	file.close()

func translate_key(key: String, arg1 = null, arg2 = null, arg3 = null) -> String:
	var raw_text = key
	if translations.has(key):
		raw_text = translations[key][current_lang]
	else:
		# Fallback if key is not found
		raw_text = key
		
	if arg1 != null and arg2 != null and arg3 != null:
		return raw_text % [arg1, arg2, arg3]
	elif arg1 != null and arg2 != null:
		return raw_text % [arg1, arg2]
	elif arg1 != null:
		return raw_text % arg1
	return raw_text

func set_language(lang: String) -> void:
	if lang == "ru" or lang == "zh":
		current_lang = lang
		# Notify main scene to redraw texts
		var main = Engine.get_meta("MainScene", null)
		if main and main.has_method("_update_localization"):
			main._update_localization()

func _parse_csv_line(line: String) -> Array:
	var result = []
	var current = ""
	var in_quotes = false
	var i = 0
	while i < line.length():
		var c = line[i]
		if c == '"':
			in_quotes = !in_quotes
		elif c == ',' and not in_quotes:
			result.append(current)
			current = ""
		else:
			current += c
		i += 1
	result.append(current)
	return result
