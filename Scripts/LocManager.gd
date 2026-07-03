extends Node

# Simple localization manager that reads from localization.csv
var current_lang = "ru" # default
var translations = {}

func _ready() -> void:
	load_translations()
	if has_node("/root/YandexSDK"):
		get_node("/root/YandexSDK").game_initialized.connect(_on_yandex_game_initialized)

func _on_yandex_game_initialized() -> void:
	if has_node("/root/YandexSDK"):
		set_language(get_node("/root/YandexSDK").get_locale())

func load_translations() -> void:
	# Initialize the translations dictionary for fallback
	translations = {}
	
	if FileAccess.file_exists("res://localization.csv"):
		var file = FileAccess.open("res://localization.csv", FileAccess.READ)
		if file:
			# Skip header
			var header = file.get_line()
			# Loop through lines
			while not file.eof_reached():
				var line = file.get_line().strip_edges()
				if line == "":
					continue
				var parts = _parse_csv_line(line)
				if parts.size() >= 3:
					var key = parts[0]
					translations[key] = {
						"ru": parts[1],
						"zh": parts[2]
					}
			file.close()
			print("[LocManager] Fallback translations dictionary populated from localization.csv.")
	
	# Load language from Yandex SDK or fallback
	if has_node("/root/YandexSDK"):
		var ysdk = get_node("/root/YandexSDK")
		current_lang = ysdk.get_locale()
	else:
		current_lang = "ru"
		
	# Synchronize Godot's locale with our current language
	TranslationServer.set_locale(current_lang)
		
	# Force redraw on startup if MainScene is already initialized
	if Engine.has_meta("MainScene"):
		var main = Engine.get_meta("MainScene")
		if main and main.has_method("_update_localization"):
			main._update_localization()

func translate_key(key: String, arg1 = null, arg2 = null, arg3 = null) -> String:
	# Use Godot's tr() which queries localization.xx.translation files compiled into the build
	var raw_text = tr(key)
	
	# Check if key is formatted UI_LEVEL, UI_TIME etc. and tr didn't translate it
	# (e.g. if tr returns the key back or if it has placeholders like %d)
	# Also fallback to translating using translations dictionary for safety if loaded
	if raw_text == key and translations.has(key):
		if translations[key].has(current_lang):
			raw_text = translations[key][current_lang]
		
	# Special fallbacks for raw keys that contain %d or %s but did not get translated
	if raw_text == key:
		if key == "UI_LEVEL":
			raw_text = "Уровень %d" if current_lang == "ru" else "等级 %d"
		elif key == "UI_TIME":
			raw_text = "Время: %dс" if current_lang == "ru" else "时间: %d秒"
		elif key == "UI_SCORE":
			raw_text = "Счет: %d" if current_lang == "ru" else "分数: %d"
		elif key == "UI_COMBO":
			raw_text = "Комбо: %d" if current_lang == "ru" else "连击: %d"
		elif key == "GAMEOVER_SCORE":
			raw_text = "Итоговый кулинарный счет: %d" if current_lang == "ru" else "最终厨艺得分: %d"
		else:
			# Fallback manually hardcoding UI translation dictionary since CSV isn't bundled on HTML5 export
			var ru_defaults = {
				"MENU_SUBTITLE": "Смешивай ингредиенты! Победи таймер!",
				"MENU_PLAY": "НАЧАТЬ ИГРУ",
				"UI_COMBINATIONS": "Рецепты",
				"UI_INGREDIENTS": "Ваши ингредиенты (Нажмите на два для слияния)",
				"UI_ROLL": "Случайный (+1 Обычный, -5с)",
				"UI_ROLL_TOOLTIP": "Тратит 5 секунд времени на получение случайного обычного предмета",
				"GAMEOVER_TITLE": "ВРЕМЯ ВЫШЛО!",
				"GAMEOVER_RESTART": "Готовить снова",
				"UI_SELECT_UPGRADE": "ВЫБЕРИТЕ УЛУЧШЕНИЕ",
				"UI_NO_RECIPES": "Нет доступных рецептов\nс текущими ингредиентами.",
				"UI_SELECT_BUTTON": "ВЫБРАТЬ"
			}
			var zh_defaults = {
				"MENU_SUBTITLE": "合成食材！战胜时间！",
				"MENU_PLAY": "开始烹饪",
				"UI_COMBINATIONS": "配方",
				"UI_INGREDIENTS": "你的食材 (点击两个进行合成)",
				"UI_ROLL": "抽取 (+1 常见, -5秒)",
				"UI_ROLL_TOOLTIP": "消耗5秒时间获得一个随机普通食材",
				"GAMEOVER_TITLE": "时间到！",
				"GAMEOVER_RESTART": "再次烹饪",
				"UI_SELECT_UPGRADE": "选择一项强化",
				"UI_NO_RECIPES": "当前食材无法\n合成任何配方。",
				"UI_SELECT_BUTTON": "选择"
			}
			if current_lang == "ru" and ru_defaults.has(key):
				raw_text = ru_defaults[key]
			elif current_lang == "zh" and zh_defaults.has(key):
				raw_text = zh_defaults[key]
				
	if arg1 != null and arg2 != null and arg3 != null:
		if "%" in raw_text:
			# Godot/GDScript formatting syntax can use % with Array
			return raw_text % [arg1, arg2, arg3]
		else:
			return raw_text + " " + str([arg1, arg2, arg3])
	elif arg1 != null and arg2 != null:
		if "%" in raw_text:
			return raw_text % [arg1, arg2]
		else:
			return raw_text + " " + str([arg1, arg2])
	elif arg1 != null:
		# Fix: if raw_text is "Уровень %d" and we have arg1 = 1, raw_text % arg1 works.
		# But sometimes tr() fails or returns a string without placeholders, so we check.
		if "%" in raw_text:
			return raw_text % arg1
		else:
			return raw_text + " " + str(arg1)
	return raw_text

func set_language(lang: String) -> void:
	if lang == "ru" or lang == "zh":
		current_lang = lang
		TranslationServer.set_locale(lang)
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
