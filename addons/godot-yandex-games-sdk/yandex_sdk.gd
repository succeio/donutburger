extends Node

signal rewarded_ad(result: String)
signal interstitial_ad(result: String)
signal game_initialized()
signal player_initialized()
signal player_ready() # Project compatibility alias
signal leaderboard_initialized()
signal data_loaded(data)
signal leaderboard_player_entry_loaded(data)
signal leaderboard_entries_loaded(data)
signal stats_loaded(stats: Dictionary)
signal check_auth(answer: bool)
signal auth_completed(success: bool) # Project compatibility alias


var is_game_initialized : bool = false
var is_game_ready : bool = false
var is_player_initialized : bool = false
var is_leaderboard_initialized: bool = false

var is_game_initialization_started: bool = false
var is_player_initialization_started: bool = false
var is_leaderboard_initialization_started: bool = false

var is_authorized: bool = false

var is_ad_on_screen: bool = false
var is_rewarded_ad_on_screen: bool = false

var app_id: String = ""
var lang: String = ""
var tld: String = ""
var payload: String = ""

# Project compatibility variables
var ysdk = null

@onready var window = JavaScriptBridge.get_interface("window")

@onready var callback_game_initialized = JavaScriptBridge.create_callback(_game_initialized)
@onready var callback_player_initialized = JavaScriptBridge.create_callback(_player_initialized)

@onready var callback_rewarded_ad = JavaScriptBridge.create_callback(_rewarded_ad)
@onready var callback_ad = JavaScriptBridge.create_callback(_interstitial_ad)
@onready var callback_is_authorized = JavaScriptBridge.create_callback(_is_authorized)

@onready var callback_data_loaded = JavaScriptBridge.create_callback(_data_loaded)
@onready var callback_stats_loaded = JavaScriptBridge.create_callback(_stats_loaded)
@onready var callback_leaderboard_player_entry_loaded = JavaScriptBridge.create_callback(_leaderboard_player_entry_loaded)
@onready var callback_leaderboard_entries_loaded = JavaScriptBridge.create_callback(_leaderboard_entries_loaded)

var _load_callback_node: Node = null
var _load_callback_method: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if is_working():
		get_window().focus_entered.connect(_update_mute)
		get_window().focus_exited.connect(_update_mute)
		init_game()


func _update_mute() -> void:
	if get_window().has_focus() and not is_ad_on_screen and not is_rewarded_ad_on_screen:
		if has_node("/root/SettingsSaves"):
			AudioServer.set_bus_mute(0, get_node("/root/SettingsSaves").load_mute_volume("Master"))
		else:
			AudioServer.set_bus_mute(0, false)
	else:
		AudioServer.set_bus_mute(0, true)

func is_working() -> bool:
	return OS.has_feature("yandex")

func open_auth_dialog() -> void:
	if not OS.has_feature("yandex"):
		return
	if not is_player_initialized:
		init_player()
		await player_initialized
	if not is_authorized:
		window.OpenAuthDialog()

func request_authorization() -> void:
	open_auth_dialog()

func check_is_authorized() -> void:
	if not OS.has_feature("yandex"):
		return
	if not is_player_initialized:
		init_player()
		await player_initialized
	if not is_authorized:
		window.CheckAuth(callback_is_authorized)

func _is_authorized(answer) -> void:
	is_authorized = answer[0]
	check_auth.emit(is_authorized)
	auth_completed.emit(is_authorized)

func init_leaderboard() -> void:
	if not OS.has_feature("yandex"):
		return
	if not is_leaderboard_initialization_started:
		is_leaderboard_initialization_started = true
		await game_initialized
		_leaderboard_initialized(null)

func init_game() -> void:
	if not OS.has_feature("yandex"):
		return
	if not is_game_initialization_started and not is_game_initialized:
		is_game_initialization_started = true
		var options = JavaScriptBridge.create_object("Object")
		window.InitGame(options, callback_game_initialized)

func game_ready() -> void:
	if not OS.has_feature("yandex"):
		return
	if not is_game_initialized:
		init_game()
		await game_initialized
	if not is_game_ready:
		is_game_ready = true
		window.GameReady()

func gameplay_started() -> void:
	if not OS.has_feature("yandex"):
		return
	if not is_game_initialized:
		init_game()
		await game_initialized
	window.GameplayStarted()

func gameplay_stopped() -> void:
	if not OS.has_feature("yandex"):
		return
	if not is_game_initialized:
		init_game()
		await game_initialized
	window.GameplayStopped()


func show_interstitial_ad() -> void:
	if not OS.has_feature("yandex"):
		return
	if not is_game_initialized:
		init_game()
		await game_initialized
	window.ShowAd(callback_ad)


func show_rewarded_ad() -> void:
	if not OS.has_feature("yandex"):
		return
	if not is_game_initialized:
		init_game()
		await game_initialized
	window.ShowAdRewardedVideo(callback_rewarded_ad)


func init_player() -> void:
	if not OS.has_feature("yandex"):
		return
	if not is_game_initialized:
		init_game()
		await game_initialized
	if is_player_initialization_started:
		return
	is_player_initialization_started = true
	window.InitPlayer(false, callback_player_initialized)


func save_data(data: Dictionary, flush: bool = false) -> void:
	if not OS.has_feature("yandex"):
		return
	if not is_player_initialized:
		init_player()
		await player_initialized
	var saves = JavaScriptBridge.create_object("Object")
	for i in data.keys():
		if data[i] is int:
			saves[i] = float(data[i])
		else:
			saves[i] = data[i]
	window.SaveData(saves, flush)

func save_cloud_data(data: Dictionary) -> void:
	save_data(data, false)

func save_stats(stats: Dictionary) -> void:
	if not OS.has_feature("yandex"):
		return
	if not is_player_initialized:
		init_player()
		await player_initialized
	var saves = JavaScriptBridge.create_object("Object")
	for i in stats.keys():
		saves[i] = float(stats[i])
	window.SaveStats(saves)


func increment_stats(increments: Dictionary) -> void:
	if not OS.has_feature("yandex"):
		return
	if not is_player_initialized:
		init_player()
		await player_initialized
	var saves = JavaScriptBridge.create_object("Object")
	for i in increments.keys():
		saves[i] = increments[i]
	window.incrementStats(saves, callback_stats_loaded)


func save_leaderboard_score(leaderboard_name, score, extra_data="") -> void:
	if not OS.has_feature("yandex"):
		return
	if not is_leaderboard_initialized:
		await leaderboard_initialized
	window.SaveLeaderboardScore(leaderboard_name, score, extra_data)

func set_leaderboard_score(leaderboard_name: String, score_val: int) -> void:
	save_leaderboard_score(leaderboard_name, score_val)


func load_all_data() -> void:
	if not OS.has_feature("yandex"):
		return
	if not is_player_initialized:
		init_player()
		await player_initialized
	window.loadAllData(callback_data_loaded)

func load_cloud_data(callback_node: Node, callback_method: String) -> void:
	_load_callback_node = callback_node
	_load_callback_method = callback_method
	if not is_player_initialized:
		init_player()
		await player_initialized
	window.loadAllData(callback_data_loaded)

func load_data(keys: Array) -> void:
	if not OS.has_feature("yandex"):
		return
	if not is_player_initialized:
		init_player()
		await player_initialized
	var saves = JavaScriptBridge.create_object("Array", keys.size())
	for i in range(keys.size()):
		saves[i] = keys[i]
	window.LoadData(saves, callback_data_loaded)


func load_all_stats() -> void:
	if not OS.has_feature("yandex"):
		return
	if not is_player_initialized:
		init_player()
		await player_initialized
	window.loadAllStats(callback_stats_loaded)


func load_stats(keys: Array) -> void:
	if not OS.has_feature("yandex"):
		return
	if not is_player_initialized:
		init_player()
		await player_initialized
	var saves = JavaScriptBridge.create_object("Array", keys.size())
	for i in range(keys.size()):
		saves[i] = keys[i]
	window.LoadStats(saves, callback_stats_loaded)


func load_leaderboard_player_entry(leaderboard_name: String) -> void:
	if not OS.has_feature("yandex"):
		return
	if not is_leaderboard_initialized:
		await leaderboard_initialized
	window.LoadLeaderboardPlayerEntry(leaderboard_name, callback_leaderboard_player_entry_loaded)


func load_leaderboard_entries(leaderboard_name: String, include_user: bool, quantity_around: int, quantity_top: int) -> void:
	if not OS.has_feature("yandex"):
		return
	if not is_leaderboard_initialized:
		await leaderboard_initialized
	window.LoadLeaderboardEntries(leaderboard_name, include_user, quantity_around, quantity_top, callback_leaderboard_entries_loaded)


func _rewarded_ad(args) -> void:
	print("rewarded ad res: ", args[0])
	match args[0]:
		"opened":
			is_rewarded_ad_on_screen = true
		"closed":
			is_rewarded_ad_on_screen = false
		"error":
			is_rewarded_ad_on_screen = false
	_update_mute()
	rewarded_ad.emit(args[0])


func _interstitial_ad(args) -> void:
	print("ad res: ", args[0])
	match args[0]:
		"opened":
			is_ad_on_screen = true
		"closed":
			is_ad_on_screen = false
		"error":
			is_ad_on_screen = false
	_update_mute()
	interstitial_ad.emit(args[0])


func _data_loaded(args) -> void:
	var result := {}
	if args[0] != null:
		var keys = JavaScriptBridge.get_interface("Object").keys(args[0])
		var values = JavaScriptBridge.get_interface("Object").values(args[0])
		for i in range(keys.length):
			result[keys[i]] = values[i]
	data_loaded.emit(result)
	if _load_callback_node and _load_callback_method != "":
		if is_instance_valid(_load_callback_node) and _load_callback_node.has_method(_load_callback_method):
			_load_callback_node.call(_load_callback_method, result)
		_load_callback_node = null
		_load_callback_method = ""


func _stats_loaded(args) -> void:
	var result := {}
	if args[0] != null:
		var keys = JavaScriptBridge.get_interface("Object").keys(args[0])
		var values = JavaScriptBridge.get_interface("Object").values(args[0])
		for i in range(keys.length):
			result[keys[i]] = values[i]
	stats_loaded.emit(result)


func _leaderboard_player_entry_loaded(args) -> void:
	if args[0] == 'loaded':
		var result := {}
		if args[1] != null:
			var keys = JavaScriptBridge.get_interface("Object").keys(args[1])
			var values = JavaScriptBridge.get_interface("Object").values(args[1])
			for i in range(keys.length):
				result[keys[i]] = values[i]
		leaderboard_player_entry_loaded.emit(result)


func _leaderboard_entries_loaded(args) -> void:
	if args[0] == 'loaded':
		var result := {}
		if args[1] != null:
			var keys = JavaScriptBridge.get_interface("Object").keys(args[1])
			var values = JavaScriptBridge.get_interface("Object").values(args[1])
			for i in range(keys.length):
				result[keys[i]] = values[i]
		leaderboard_entries_loaded.emit(result)
	elif args[0] == 'error':
		print("Произошла ошибка при загрузке лидерборда.")


func _game_initialized(args) -> void:
	app_id = args[0].app.id
	lang = args[0].i18n.lang
	tld = args[0].i18n.tld
	if args[0].payload == null: payload = ""
	else: payload = args[0].payload
	is_game_initialized = true
	ysdk = window
	TranslationServer.set_locale(lang)
	game_initialized.emit()
	init_player()
	init_leaderboard()


func _player_initialized(args) -> void:
	is_player_initialized = true
	check_is_authorized()
	player_initialized.emit()
	player_ready.emit()


func _leaderboard_initialized(args) -> void:
	is_leaderboard_initialized = true
	leaderboard_initialized.emit()

# Project compatibility locale detection helper
func get_locale() -> String:
	if lang != "":
		if lang.begins_with("zh"):
			return "zh"
		return "ru"
	# Fallback navigator detection
	if window:
		var navigator = JavaScriptBridge.get_interface("navigator")
		if navigator:
			var browser_lang = navigator.language
			if browser_lang.begins_with("zh"):
				return "zh"
	return "ru"
