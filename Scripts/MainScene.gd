extends Node3D

@onready var start_menu = $UI/StartMenu
@onready var play_button = $UI/StartMenu/VBox/PlayButton
@onready var btn_ru = $UI/StartMenu/VBox/LanguageContainer/BtnRU
@onready var btn_zh = $UI/StartMenu/VBox/LanguageContainer/BtnZH
@onready var main_layout = $UI/MainLayout
@onready var recipe_list = $UI/MainLayout/LeftPanel/VBox/Scroll/RecipeList
@onready var inventory_grid = $UI/MainLayout/RightPanel/VBox/Scroll/InventoryGrid
@onready var left_panel_title = $UI/MainLayout/LeftPanel/VBox/Title
@onready var right_panel_title = $UI/MainLayout/RightPanel/VBox/InventoryTitle
@onready var time_label = $UI/MainLayout/RightPanel/VBox/StatusContainer/TimeLabel
@onready var roll_button = $UI/MainLayout/RightPanel/VBox/BottomControls/RollButton
@onready var game_over_overlay = $UI/GameOverOverlay
@onready var game_over_title = $UI/GameOverOverlay/VBox/Title
@onready var score_label = $UI/GameOverOverlay/VBox/ScoreLabel
@onready var restart_button = $UI/GameOverOverlay/VBox/RestartButton
@onready var food_pivot = $FoodPivot
@onready var level_progress_bar = $UI/MainLayout/CenterSpace/XPProgressBar
@onready var level_label = $UI/MainLayout/CenterSpace/LevelLabel
@onready var upgrade_overlay = $UI/UpgradeOverlay
@onready var upgrade_cards_container = $UI/UpgradeOverlay/VBox/CardsContainer
@onready var upgrade_title = $UI/UpgradeOverlay/VBox/Title
@onready var upgrades_list = $UI/MainLayout/CenterSpace/UpgradesList

var selected_inventory_index: int = -1
var food_3d_node: Node3D = null

# For random menu backgrounds
var menu_mode: bool = true
var menu_rotation_speed: float = 0.5
var menu_switch_timer: float = 0.0
# Grid of floating food objects in the menu
var menu_background_foods: Array[Node3D] = []

func _ready() -> void:
	Engine.set_meta("MainScene", self)
	GameState.time_changed.connect(_on_time_changed)
	GameState.game_over.connect(_on_game_over)
	GameState.food_list_updated.connect(_update_ui)
	GameState.food_combined.connect(trigger_combine_popup)
	
	# Connect to window resizing events to restrict aspect ratio to 2:1 on wide desktop layouts
	get_tree().root.size_changed.connect(_on_window_resize)
	_on_window_resize()
	
	roll_button.pressed.connect(_on_roll_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	play_button.pressed.connect(_on_play_pressed)
	
	btn_ru.pressed.connect(func(): LocManager.set_language("ru"))
	btn_zh.pressed.connect(func(): LocManager.set_language("zh"))
	
	# Add Yandex ID Login button dynamically inside LanguageContainer if running on Web and SDK is loaded
	if YandexSDK.ysdk:
		var auth_btn = Button.new()
		auth_btn.text = "Войти / Login Yandex ID"
		auth_btn.add_theme_color_override("font_color", Color.WHITE)
		var auth_style = StyleBoxFlat.new()
		auth_style.bg_color = Color(0.9, 0.2, 0.2)
		auth_style.set_corner_radius_all(8)
		auth_style.set_content_margin_all(8)
		auth_btn.add_theme_stylebox_override("normal", auth_style)
		auth_btn.pressed.connect(func(): YandexSDK.request_authorization())
		$UI/StartMenu/VBox/LanguageContainer.add_child(auth_btn)
		
		# Hook up load cloud data if authorized
		YandexSDK.player_ready.connect(func():
			if YandexSDK.is_authorized:
				YandexSDK.load_cloud_data(self, "_on_yandex_cloud_data_loaded")
		)
	
	_setup_popup_ui()
	_setup_kitchen_scene()
	
	# Connect to game restart/play to clear cooked food models
	restart_button.pressed.connect(func(): _clear_cooked_food_visuals())
	play_button.pressed.connect(func(): _clear_cooked_food_visuals())
	
	GameState.level_changed.connect(_on_level_changed)
	GameState.level_rewarded.connect(_queue_reward_popup)
	GameState.level_up_pending.connect(_on_level_up_pending)
	GameState.upgrades_updated.connect(_on_upgrades_updated)
	
	# Start in menu mode, display random rotating food
	menu_mode = true
	main_layout.visible = false
	start_menu.visible = true
	_setup_start_menu_visuals()
	_update_localization()
	_show_random_menu_food()
	YandexSDK.game_ready()

func _setup_start_menu_visuals() -> void:
	# Add beautiful text outline, colors and styling to Start Menu
	var subtitle_lbl = $UI/StartMenu/VBox/SubTitle
	var play_btn = $UI/StartMenu/VBox/PlayButton
	
	# Subtitle styling
	subtitle_lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 0.95))
	subtitle_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1.0))
	subtitle_lbl.add_theme_constant_override("outline_size", 8)
	
	# Play Button styling
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color(0.15, 0.65, 0.25) # Vibrant green
	btn_normal.set_border_width_all(3)
	btn_normal.border_color = Color(0.8, 1.0, 0.8)
	btn_normal.set_corner_radius_all(12)
	btn_normal.shadow_color = Color(0, 0, 0, 0.4)
	btn_normal.shadow_size = 8
	
	var btn_hover = btn_normal.duplicate()
	btn_hover.bg_color = Color(0.2, 0.8, 0.3) # Brighter green
	
	var btn_pressed = btn_normal.duplicate()
	btn_pressed.bg_color = Color(0.1, 0.5, 0.18)
	
	play_btn.add_theme_stylebox_override("normal", btn_normal)
	play_btn.add_theme_stylebox_override("hover", btn_hover)
	play_btn.add_theme_stylebox_override("pressed", btn_pressed)
	play_btn.add_theme_color_override("font_color", Color.WHITE)
	play_btn.add_theme_color_override("font_outline_color", Color.BLACK)
	play_btn.add_theme_constant_override("outline_size", 6)

func _show_random_menu_food() -> void:
	_clear_menu_background_foods()
	
	var keys = DataManager.foods.keys()
	if keys.size() == 0:
		return
		
	# Create a dense grid of random food items across the 3D space behind the menu
	# We place them at different X and Y offsets, but keep Z deep enough
	var colormap_tex = load("res://Models/OBJ format/Textures/colormap.png")
	
	for x_slot in range(-5, 6, 2): # Steps of 2 units from -5 to 5
		for y_slot in range(-3, 6, 2):
			var random_food = keys[randi() % keys.size()]
			var food_data = DataManager.foods[random_food]
			var mesh = load(food_data["model"])
			if mesh:
				var mesh_instance = MeshInstance3D.new()
				mesh_instance.mesh = mesh
				
				# Apply spatial glow shader to background foods too
				var shader_material = ShaderMaterial.new()
				shader_material.shader = load("res://Shaders/food_glow.gdshader")
				if colormap_tex:
					shader_material.set_shader_parameter("albedo_texture", colormap_tex)
				
				# Random subtle colored glow for menu elements
				var rand_rarity = randi() % 5
				var rarity_color = DataManager.RARITY_INFO[rand_rarity]["color"]
				shader_material.set_shader_parameter("rim_color", rarity_color)
				shader_material.set_shader_parameter("rim_intensity", 1.2)
				shader_material.set_shader_parameter("rim_power", 4.0)
				
				mesh_instance.material_override = shader_material
				
				# Scale based on bounds
				var aabb = mesh.get_aabb()
				var max_size = max(aabb.size.x, max(aabb.size.y, aabb.size.z))
				var target_scale = 1.2 / (max_size if max_size > 0.001 else 0.12)
				mesh_instance.scale = Vector3(target_scale, target_scale, target_scale)
				
				# Position relative to camera view
				var target_pos = Vector3(x_slot * 1.5, y_slot * 1.5, -2.0)
				# Offset slightly to center mesh pivot
				var offset_pivot = (-aabb.position - (aabb.size / 2.0)) * target_scale
				mesh_instance.position = target_pos + offset_pivot
				
				# Give random starting rotation
				mesh_instance.rotation_degrees = Vector3(
					randf_range(0, 360),
					randf_range(0, 360),
					randf_range(0, 360)
				)
				
				# Store rotation speeds on the instance meta properties
				mesh_instance.set_meta("rot_speed_x", randf_range(-0.8, 0.8))
				mesh_instance.set_meta("rot_speed_y", randf_range(-0.8, 0.8))
				mesh_instance.set_meta("rot_speed_z", randf_range(-0.8, 0.8))
				
				food_pivot.add_child(mesh_instance)
				menu_background_foods.append(mesh_instance)

func _clear_menu_background_foods() -> void:
	for node in menu_background_foods:
		if is_instance_valid(node):
			node.queue_free()
	menu_background_foods.clear()

func _on_play_pressed() -> void:
	selected_inventory_index = -1
	menu_mode = false
	start_menu.visible = false
	main_layout.visible = true
	_clear_menu_background_foods()
	_clear_3d_food()
	AudioManager.play_sfx("res://Audio/maximize_001.ogg")
	GameState.start_game()

func _on_yandex_cloud_data_loaded(data: Dictionary) -> void:
	if data.has("inventory"):
		GameState.inventory = data["inventory"]
	if data.has("level"):
		GameState.current_level = data["level"]
	if data.has("upgrades"):
		GameState.active_upgrades = data["upgrades"]
	GameState.emit_signal("food_list_updated")

func _on_window_resize() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	if viewport_size.y > 0:
		var aspect = viewport_size.x / viewport_size.y
		# Enforce Yandex Games aspect ratio requirement (max 2:1 ratio for playable area)
		# We adjust MainLayout (Control node) since UI (CanvasLayer) doesn't have transform limits.
		var main_layout_node = $UI/MainLayout
		if aspect > 2.0:
			var max_width = viewport_size.y * 2.0
			main_layout_node.custom_minimum_size.x = max_width
			# Center UI container in window
			var offset = (viewport_size.x - max_width) / 2.0
			main_layout_node.position.x = offset
		else:
			main_layout_node.custom_minimum_size.x = 0
			main_layout_node.position.x = 0

var popup_panel: PanelContainer = null
var popup_label: Label = null
var popup_texture: TextureRect = null
var popup_glow: Control = null
var popup_tween: Tween = null

var popup_queue: Array = []
var is_displaying_popup: bool = false

func _setup_popup_ui() -> void:
	popup_panel = PanelContainer.new()
	popup_panel.visible = false
	popup_panel.custom_minimum_size = Vector2(300, 220)
	
	popup_panel.anchors_preset = Control.PRESET_CENTER
	popup_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	popup_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.08, 0.09, 0.96)
	sb.set_border_width_all(5)
	sb.border_color = Color.GOLD
	sb.set_corner_radius_all(16)
	# Add a slight drop shadow to the panel itself to give a "premium chest loot" look
	sb.shadow_color = Color(0, 0, 0, 0.6)
	sb.shadow_size = 12
	popup_panel.add_theme_stylebox_override("panel", sb)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 15)
	
	var congrats = Label.new()
	congrats.text = "ITEM FOUND!"
	congrats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	congrats.add_theme_font_size_override("font_size", 14)
	congrats.add_theme_color_override("font_color", Color.GOLD)
	
	popup_glow = Control.new()
	popup_glow.custom_minimum_size = Vector2(100, 100)
	popup_glow.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	var glow_panel = Panel.new()
	glow_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	glow_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	glow_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	var glow_sb = StyleBoxFlat.new()
	glow_sb.bg_color = Color(1, 0.85, 0, 0.1)
	glow_sb.set_corner_radius_all(50)
	# Smaller shadow size for subtle glow effect
	glow_sb.shadow_color = Color(1, 0.85, 0, 0.95)
	glow_sb.shadow_size = 15
	glow_panel.add_theme_stylebox_override("panel", glow_sb)
	popup_glow.add_child(glow_panel)
	
	# Container to wrap and center texture perfectly inside Control
	var texture_container = CenterContainer.new()
	texture_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	texture_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	texture_container.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	popup_texture = TextureRect.new()
	popup_texture.custom_minimum_size = Vector2(90, 90)
	popup_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	popup_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	texture_container.add_child(popup_texture)
	popup_glow.add_child(texture_container)
	
	popup_label = Label.new()
	popup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup_label.add_theme_font_size_override("font_size", 24)
	
	vbox.add_child(congrats)
	vbox.add_child(popup_glow)
	vbox.add_child(popup_label)
	popup_panel.add_child(vbox)
	
	$UI.add_child(popup_panel)
	
	# Force anchor reset and layout calculation
	popup_panel.set_anchors_preset(Control.PRESET_CENTER)
	popup_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	popup_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	# Set direct position offset to avoid top-left default alignment in CanvasLayer
	# Shift the pop-up higher (Y offset = -140 pixels from center) to prevent overlapping with cards/perks
	popup_panel.position = (Vector2(1152, 648) - popup_panel.custom_minimum_size) / 2.0 - Vector2(0, 140)

# Keep track of spawned food models cooked during the game
var cooked_food_models: Array[Node3D] = []

func _clear_cooked_food_visuals() -> void:
	for node in cooked_food_models:
		if is_instance_valid(node):
			node.queue_free()
	cooked_food_models.clear()

func trigger_combine_popup(food_id: String) -> void:
	_queue_popup({"type": "combine", "food_id": food_id})

func _queue_reward_popup(food_id: String) -> void:
	_queue_popup({"type": "reward", "food_id": food_id})

func _queue_popup(info: Dictionary) -> void:
	popup_queue.append(info)
	if not is_displaying_popup:
		_show_next_popup()

func _show_next_popup() -> void:
	if popup_queue.is_empty():
		is_displaying_popup = false
		return
		
	is_displaying_popup = true
	var current = popup_queue.pop_front()
	var food_id = current["food_id"]
	var is_reward = current["type"] == "reward"
	
	if not DataManager.foods.has(food_id):
		_show_next_popup()
		return
		
	# Add physical visual reward if it was combined
	if current["type"] == "combine":
		var colormap_tex = load("res://Models/OBJ format/Textures/colormap.png")
		var food_data = DataManager.foods[food_id]
		var mesh = load(food_data["model"])
		var kitchen_scene = get_node_or_null("KitchenScene")
		if mesh and kitchen_scene:
			var inst = MeshInstance3D.new()
			inst.mesh = mesh
			
			var shader_material = ShaderMaterial.new()
			shader_material.shader = load("res://Shaders/food_glow.gdshader")
			if colormap_tex:
				shader_material.set_shader_parameter("albedo_texture", colormap_tex)
				
			var rarity_color = DataManager.RARITY_INFO[food_data["rarity"]]["color"]
			shader_material.set_shader_parameter("rim_color", rarity_color)
			shader_material.set_shader_parameter("rim_intensity", 1.5)
			shader_material.set_shader_parameter("rim_power", 3.0)
			inst.material_override = shader_material
			
			var aabb = mesh.get_aabb()
			var max_size = max(aabb.size.x, max(aabb.size.y, aabb.size.z))
			var target_scale = 0.6 / (max_size if max_size > 0.001 else 1.0)
			inst.scale = Vector3(target_scale, target_scale, target_scale)
			
			var offset_pivot = (-aabb.position - (aabb.size / 2.0))
			var random_x = randf_range(-5.0, 5.0)
			var random_z = randf_range(-5.0, -2.0)
			var distance_factor = 1.0 + (abs(random_z) - 2.0) * 0.8
			var base_scale = 0.6 / (max_size if max_size > 0.001 else 1.0)
			var target_scale_val = base_scale * distance_factor
			offset_pivot *= target_scale_val
			
			var random_pos = Vector3(
				random_x,
				0.02 + (abs(random_z) - 2.0) * 0.4,
				random_z
			)
			inst.position = random_pos + offset_pivot
			inst.rotation_degrees = Vector3(0, randf_range(0, 360), 0)
			
			kitchen_scene.add_child(inst)
			cooked_food_models.append(inst)
			
			var spawn_tween = create_tween()
			inst.scale = Vector3.ZERO
			spawn_tween.tween_property(inst, "scale", Vector3(target_scale_val, target_scale_val, target_scale_val), 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			
	var data = DataManager.foods[food_id]
	popup_label.text = LocManager.translate_key(data["name"])
	popup_texture.texture = load(data["preview"])
	
	var rarity_color = DataManager.RARITY_INFO[data["rarity"]]["color"]
	
	# Match congrats text
	var congrats_label = popup_panel.get_child(0).get_child(0) as Label
	if is_reward:
		congrats_label.text = LocManager.translate_key("POPUP_LEVEL_UP")
		congrats_label.add_theme_color_override("font_color", rarity_color)
	else:
		var rarity_name_key = DataManager.RARITY_INFO[data["rarity"]]["name"]
		var rarity_translated = LocManager.translate_key(rarity_name_key).to_upper()
		congrats_label.text = LocManager.translate_key("POPUP_FOUND", rarity_translated)
		congrats_label.add_theme_color_override("font_color", rarity_color)
	
	var sb = popup_panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	sb.border_color = rarity_color
	sb.set_border_width_all(5)
	popup_panel.add_theme_stylebox_override("panel", sb)
	
	var glow_sb = popup_glow.get_child(0).get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	glow_sb.bg_color = rarity_color
	glow_sb.bg_color.a = 0.15
	glow_sb.shadow_color = rarity_color
	glow_sb.shadow_color.a = 0.95
	glow_sb.shadow_size = 18
	popup_glow.get_child(0).add_theme_stylebox_override("panel", glow_sb)
	
	popup_label.add_theme_color_override("font_color", rarity_color)
	
	popup_panel.visible = true
	popup_panel.set_anchors_preset(Control.PRESET_CENTER)
	popup_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	popup_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	var viewport_size = popup_panel.get_viewport_rect().size
	# Shift the pop-up higher (Y offset = -140 pixels from center) to prevent overlapping with cards/perks
	popup_panel.position = (viewport_size - popup_panel.custom_minimum_size) / 2.0 - Vector2(0, 140)
	
	popup_panel.scale = Vector2(0.1, 0.1)
	popup_panel.pivot_offset = popup_panel.custom_minimum_size / 2.0
	
	if popup_tween:
		popup_tween.kill()
		
	popup_tween = create_tween()
	popup_tween.set_parallel(false)
	popup_tween.tween_property(popup_panel, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	popup_tween.tween_interval(1.5)
	popup_tween.tween_property(popup_panel, "scale", Vector2(0.0, 0.0), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	popup_tween.tween_callback(func():
		popup_panel.visible = false
		_show_next_popup()
	)

func _populate_recipes_ui() -> void:
	for child in recipe_list.get_children():
		child.queue_free()
		
	# Find recipes that can be made from items currently in the player's inventory
	# Count items in inventory
	var inventory_counts = {}
	for food_id in GameState.inventory:
		inventory_counts[food_id] = inventory_counts.get(food_id, 0) + 1
		
	# Check normal recipes
	var available_recipes = []
	for recipe in DataManager.recipes:
		var in1 = recipe["inputs"][0]
		var in2 = recipe["inputs"][1]
		
		# If they are different, we need at least 1 of each
		if in1 != in2:
			if inventory_counts.get(in1, 0) > 0 and inventory_counts.get(in2, 0) > 0:
				available_recipes.append(recipe)
		else:
			# If they are the same
			if inventory_counts.get(in1, 0) > 1:
				available_recipes.append(recipe)
				
	# Check 3x identical item upgrade recipes
	# For each unique item in inventory with count >= 3, show a special upgrade combo recipe
	var identical_upgrades = []
	for food_id in inventory_counts:
		if inventory_counts[food_id] >= 3:
			var next_tier = DataManager.get_next_tier_food(food_id)
			if next_tier != "":
				identical_upgrades.append({
					"inputs": [food_id, food_id, food_id],
					"output": next_tier,
					"is_triple": true
				})
				
	# Render 3x triple upgrades first
	for upgrade in identical_upgrades:
		var item_container = HBoxContainer.new()
		item_container.custom_minimum_size = Vector2(0, 50)
		item_container.alignment = BoxContainer.ALIGNMENT_CENTER
		
		var food_data = DataManager.foods[upgrade["inputs"][0]]
		
		var label_3x = Label.new()
		label_3x.text = "3x "
		label_3x.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label_3x.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		var in_rect = TextureRect.new()
		in_rect.custom_minimum_size = Vector2(40, 40)
		in_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		in_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		in_rect.texture = load(food_data["preview"])
		in_rect.tooltip_text = LocManager.translate_key(food_data["name"])
		
		var arrow = Label.new()
		arrow.text = " -> "
		arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		# Output
		var out = upgrade["output"]
		var out_data = DataManager.foods[out]
		var out_rect = TextureRect.new()
		out_rect.custom_minimum_size = Vector2(48, 48)
		out_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		out_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		out_rect.texture = load(out_data["preview"])
		out_rect.tooltip_text = LocManager.translate_key(out_data["name"]) + " (Random next-tier)"
		
		var panel = PanelContainer.new()
		var sb = StyleBoxFlat.new()
		sb.bg_color = DataManager.RARITY_INFO[out_data["rarity"]]["color"]
		sb.bg_color.a = 0.25
		sb.set_border_width_all(2)
		sb.border_color = DataManager.RARITY_INFO[out_data["rarity"]]["color"]
		sb.set_corner_radius_all(6)
		panel.add_theme_stylebox_override("panel", sb)
		
		item_container.add_child(label_3x)
		item_container.add_child(in_rect)
		item_container.add_child(arrow)
		panel.add_child(out_rect)
		item_container.add_child(panel)
		
		recipe_list.add_child(item_container)
		
	# Render normal 2-ingredient recipes
	for recipe in available_recipes:
		var item_container = HBoxContainer.new()
		item_container.custom_minimum_size = Vector2(0, 50)
		item_container.alignment = BoxContainer.ALIGNMENT_CENTER
		
		# Input 1
		var in1 = recipe["inputs"][0]
		var in1_data = DataManager.foods[in1]
		var in1_rect = TextureRect.new()
		in1_rect.custom_minimum_size = Vector2(40, 40)
		in1_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		in1_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		in1_rect.texture = load(in1_data["preview"])
		in1_rect.tooltip_text = LocManager.translate_key(in1_data["name"])
		
		# Plus sign
		var plus = Label.new()
		plus.text = "+"
		plus.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		plus.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		# Input 2
		var in2 = recipe["inputs"][1]
		var in2_data = DataManager.foods[in2]
		var in2_rect = TextureRect.new()
		in2_rect.custom_minimum_size = Vector2(40, 40)
		in2_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		in2_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		in2_rect.texture = load(in2_data["preview"])
		in2_rect.tooltip_text = LocManager.translate_key(in2_data["name"])
		
		# Arrow sign
		var arrow = Label.new()
		arrow.text = " -> "
		arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		# Output
		var out = recipe["output"]
		var out_data = DataManager.foods[out]
		var out_rect = TextureRect.new()
		out_rect.custom_minimum_size = Vector2(48, 48)
		out_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		out_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		out_rect.texture = load(out_data["preview"])
		out_rect.tooltip_text = LocManager.translate_key(out_data["name"])
		
		# Rarity background panel or color modulation
		var panel = PanelContainer.new()
		var sb = StyleBoxFlat.new()
		sb.bg_color = DataManager.RARITY_INFO[out_data["rarity"]]["color"]
		sb.bg_color.a = 0.25
		sb.set_border_width_all(2)
		sb.border_color = DataManager.RARITY_INFO[out_data["rarity"]]["color"]
		sb.set_corner_radius_all(6)
		panel.add_theme_stylebox_override("panel", sb)
		
		item_container.add_child(in1_rect)
		item_container.add_child(plus)
		item_container.add_child(in2_rect)
		item_container.add_child(arrow)
		
		panel.add_child(out_rect)
		item_container.add_child(panel)
		
		recipe_list.add_child(item_container)
		
	if available_recipes.size() == 0 and identical_upgrades.size() == 0:
		var empty_label = Label.new()
		empty_label.text = LocManager.translate_key("UI_NO_RECIPES")
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		recipe_list.add_child(empty_label)

func _update_ui() -> void:
	# Clear old items
	for child in inventory_grid.get_children():
		child.queue_free()
		
	# Store the currently selected index before clearing
	var old_selected_index = selected_inventory_index
	
	# Regenerate recipes list on the left based on updated inventory
	_populate_recipes_ui()
	
	# Populate inventory
	for i in range(GameState.inventory.size()):
		var food_id = GameState.inventory[i]
		var food_data = DataManager.foods[food_id]
		
		var button = Button.new()
		button.custom_minimum_size = Vector2(80, 80)
		button.flat = false
		
		# Set styling according to rarity color
		var sb_normal = StyleBoxFlat.new()
		var color = DataManager.RARITY_INFO[food_data["rarity"]]["color"]
		sb_normal.bg_color = color * 0.4
		sb_normal.bg_color.a = 0.8
		sb_normal.set_border_width_all(2)
		sb_normal.border_color = color
		sb_normal.set_corner_radius_all(8)
		
		var sb_hover = sb_normal.duplicate()
		sb_hover.bg_color = color * 0.6
		
		var sb_pressed = sb_normal.duplicate()
		sb_pressed.bg_color = color * 0.8
		sb_pressed.border_color = Color.WHITE
		
		if old_selected_index == i:
			sb_normal.border_color = Color.WHITE
			sb_normal.bg_color = color * 0.8
		
		button.add_theme_stylebox_override("normal", sb_normal)
		button.add_theme_stylebox_override("hover", sb_hover)
		button.add_theme_stylebox_override("pressed", sb_pressed)
		
		var texture_rect = TextureRect.new()
		texture_rect.custom_minimum_size = Vector2(64, 64)
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.texture = load(food_data["preview"])
		texture_rect.anchors_preset = Control.PRESET_FULL_RECT
		texture_rect.mouse_filter = Control.MOUSE_FILTER_PASS
		button.add_child(texture_rect)
		
		# Tooltip
		var rarity_name_key = DataManager.RARITY_INFO[food_data["rarity"]]["name"]
		button.tooltip_text = "%s (%s)\nScore Value: %d" % [
			LocManager.translate_key(food_data["name"]),
			LocManager.translate_key(rarity_name_key),
			DataManager.RARITY_INFO[food_data["rarity"]]["value"]
		]
		
		# Setup click connection
		button.pressed.connect(_on_inventory_button_pressed.bind(i))
		
		inventory_grid.add_child(button)

func _on_inventory_button_pressed(index: int) -> void:
	if index >= GameState.inventory.size():
		return
		
	if selected_inventory_index == -1:
		# Select first item
		selected_inventory_index = index
		_update_ui()
		_show_3d_food(GameState.inventory[index])
		AudioManager.play_sfx("res://Audio/click_002.ogg")
	else:
		if selected_inventory_index == index:
			# Deselect
			selected_inventory_index = -1
			_update_ui()
			_clear_3d_food()
			AudioManager.play_sfx("res://Audio/click_005.ogg")
		else:
			# Attempt combine
			var old_idx = selected_inventory_index
			# Reset selected index first so that _update_ui() triggered by signals works fine
			selected_inventory_index = -1
			
			# Check bounds before reading
			if old_idx >= GameState.inventory.size() or index >= GameState.inventory.size():
				_update_ui()
				return
				
			var success = GameState.combine_items(old_idx, index)
			if not success:
				# If not successful, just change selection to the new item
				selected_inventory_index = index
				_update_ui()
				_show_3d_food(GameState.inventory[index])
				AudioManager.play_sfx("res://Audio/click_002.ogg")
				AudioManager.play_sfx("res://Audio/error_001.ogg")
			else:
				# Combination succeeded, list is already updated via signal
				_clear_3d_food()

func _show_3d_food(food_id: String) -> void:
	_clear_3d_food()
	
	var food_data = DataManager.foods[food_id]
	var mesh = load(food_data["model"])
	if mesh:
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = mesh
		
		# Load and apply custom spatial shader with rim/fresnel glow effect
		var shader_material = ShaderMaterial.new()
		shader_material.shader = load("res://Shaders/food_glow.gdshader")
		
		var texture = load("res://Models/OBJ format/Textures/colormap.png")
		if texture:
			shader_material.set_shader_parameter("albedo_texture", texture)
			
		# Make selected/rare products glow with their rarity color
		var rarity_color = DataManager.RARITY_INFO[food_data["rarity"]]["color"]
		shader_material.set_shader_parameter("rim_color", rarity_color)
		shader_material.set_shader_parameter("rim_intensity", 1.8)
		shader_material.set_shader_parameter("rim_power", 3.0)
		
		mesh_instance.material_override = shader_material
		
		food_pivot.add_child(mesh_instance)
		food_3d_node = mesh_instance
		
		# Calculate bounds of the mesh to normalize scale dynamically
		var aabb = mesh.get_aabb()
		var max_size = max(aabb.size.x, max(aabb.size.y, aabb.size.z))
		if max_size > 0.001:
			var target_scale = 1.6 / max_size
			mesh_instance.scale = Vector3(target_scale, target_scale, target_scale)
			# Center the mesh pivot based on AABB
			mesh_instance.position = (-aabb.position - (aabb.size / 2.0)) * target_scale
		else:
			# Fallback size and scale normalization for models that might not report valid aabb immediately
			mesh_instance.scale = Vector3(10.0, 10.0, 10.0)
			mesh_instance.position = Vector3.ZERO
			
		mesh_instance.rotation_degrees = Vector3(15, 0, 0)

func _clear_3d_food() -> void:
	if food_3d_node and is_instance_valid(food_3d_node):
		food_3d_node.queue_free()
	food_3d_node = null

func _process(delta: float) -> void:
	if menu_mode:
		# Rotate all background food items in menu
		for node in menu_background_foods:
			if is_instance_valid(node):
				node.rotate_x(delta * node.get_meta("rot_speed_x", 0.3))
				node.rotate_y(delta * node.get_meta("rot_speed_y", 0.5))
				node.rotate_z(delta * node.get_meta("rot_speed_z", 0.2))
				
		menu_switch_timer += delta
		# Switch all background foods every 8 seconds for visual freshness
		if menu_switch_timer >= 8.0:
			menu_switch_timer = 0.0
			_show_random_menu_food()
	else:
		if food_3d_node and is_instance_valid(food_3d_node):
			food_3d_node.rotate_y(delta * 1.0)

func _on_time_changed(seconds: int) -> void:
	time_label.text = LocManager.translate_key("UI_TIME", seconds)
	if seconds <= 10:
		time_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	else:
		time_label.remove_theme_color_override("font_color")

func _on_level_changed(level: int, xp: int, xp_needed: int) -> void:
	level_label.text = LocManager.translate_key("UI_LEVEL", level)
	level_progress_bar.max_value = xp_needed
	level_progress_bar.value = xp

func _on_upgrades_updated(active_upgrades: Dictionary) -> void:
	# Clear active icons
	for child in upgrades_list.get_children():
		child.queue_free()
		
	for upgrade_key in active_upgrades:
		var count = active_upgrades[upgrade_key]
		if count <= 0:
			continue
			
		var upgrade_rarity = GameState.UPGRADES[upgrade_key]["rarity"]
		var color = DataManager.RARITY_INFO[upgrade_rarity]["color"]
			
		var panel = PanelContainer.new()
		var sb = StyleBoxFlat.new()
		sb.bg_color = color * 0.15
		sb.bg_color.a = 0.85
		sb.border_color = color
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(8)
		panel.add_theme_stylebox_override("panel", sb)
		
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 8)
		margin.add_theme_constant_override("margin_right", 8)
		margin.add_theme_constant_override("margin_top", 4)
		margin.add_theme_constant_override("margin_bottom", 4)
		
		var lbl = Label.new()
		var upgrade_name = LocManager.translate_key(GameState.UPGRADES[upgrade_key]["name"])
		lbl.text = "%s x%d" % [upgrade_name, count]
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95))
		
		margin.add_child(lbl)
		panel.add_child(margin)
		upgrades_list.add_child(panel)

func _on_level_up_pending(options: Array) -> void:
	# Clear old cards
	for child in upgrade_cards_container.get_children():
		child.queue_free()
		
	upgrade_overlay.visible = true
	
	# Create a TF2-styled card for each option
	for upgrade_key in options:
		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(180, 240)
		
		# Get rarity of the upgrade
		var upgrade_rarity = GameState.UPGRADES[upgrade_key]["rarity"]
		var rarity_color = DataManager.RARITY_INFO[upgrade_rarity]["color"]
		
		# Stylish Panel look matching rarity color
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color(0.12, 0.12, 0.16, 0.95)
		sb.border_color = rarity_color
		sb.set_border_width_all(3)
		sb.set_corner_radius_all(10)
		sb.shadow_color = Color(0, 0, 0, 0.5)
		sb.shadow_size = 6
		card.add_theme_stylebox_override("panel", sb)
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 15)
		
		# Upgrade name
		var name_lbl = Label.new()
		name_lbl.text = LocManager.translate_key(GameState.UPGRADES[upgrade_key]["name"])
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_lbl.add_theme_font_size_override("font_size", 18)
		name_lbl.add_theme_color_override("font_color", rarity_color)
		vbox.add_child(name_lbl)
		
		# Upgrade description
		var desc_lbl = Label.new()
		desc_lbl.text = LocManager.translate_key(GameState.UPGRADES[upgrade_key]["desc"])
		desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.add_theme_font_size_override("font_size", 13)
		desc_lbl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
		vbox.add_child(desc_lbl)
		
		# Select button
		var select_btn = Button.new()
		select_btn.text = LocManager.translate_key("UI_SELECT_BUTTON")
		select_btn.custom_minimum_size = Vector2(100, 35)
		select_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		
		# Stylish button matches rarity theme
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = rarity_color * 0.7
		btn_style.set_corner_radius_all(6)
		select_btn.add_theme_stylebox_override("normal", btn_style)
		
		var btn_style_hover = btn_style.duplicate()
		btn_style_hover.bg_color = rarity_color
		select_btn.add_theme_stylebox_override("hover", btn_style_hover)
		
		# Bind click logic
		select_btn.pressed.connect(func():
			GameState.select_upgrade(upgrade_key)
			upgrade_overlay.visible = false
			AudioManager.play_sfx("res://Audio/maximize_001.ogg")
		)
		
		vbox.add_child(select_btn)
		card.add_child(vbox)
		upgrade_cards_container.add_child(card)

func _on_game_over(score: int) -> void:
	score_label.text = LocManager.translate_key("GAMEOVER_SCORE", score)
	main_layout.visible = false
	game_over_overlay.visible = true

func _on_roll_pressed() -> void:
	if not GameState.game_active:
		return
		
	var success = GameState.roll_ingredient()
	if success:
		AudioManager.play_sfx("res://Audio/switch_001.ogg")

func _on_restart_pressed() -> void:
	selected_inventory_index = -1
	AudioManager.play_sfx("res://Audio/maximize_001.ogg")
	game_over_overlay.visible = false
	menu_mode = true
	start_menu.visible = true
	_setup_start_menu_visuals()
	_update_localization()
	_show_random_menu_food()

func _update_localization() -> void:
	# Update all static text in UI based on selected language
	var subtitle_lbl = $UI/StartMenu/VBox/SubTitle
	var play_btn = $UI/StartMenu/VBox/PlayButton
	
	subtitle_lbl.text = LocManager.translate_key("MENU_SUBTITLE")
	play_btn.text = LocManager.translate_key("MENU_PLAY")
	
	left_panel_title.text = LocManager.translate_key("UI_COMBINATIONS")
	right_panel_title.text = LocManager.translate_key("UI_INGREDIENTS")
	roll_button.text = LocManager.translate_key("UI_ROLL")
	roll_button.tooltip_text = LocManager.translate_key("UI_ROLL_TOOLTIP")
	
	level_label.text = LocManager.translate_key("UI_LEVEL", GameState.current_level)
	
	game_over_title.text = LocManager.translate_key("GAMEOVER_TITLE")
	restart_button.text = LocManager.translate_key("GAMEOVER_RESTART")
	
	upgrade_title.text = LocManager.translate_key("UI_SELECT_UPGRADE")
	
	_update_ui()

func _setup_kitchen_scene() -> void:
	var kitchen_scene = get_node_or_null("KitchenScene")
	if not kitchen_scene:
		return
		
	var colormap_tex = load("res://Models/OBJ format/Textures/colormap.png")
	
	# Central cutting board
	var cutting_board_mesh = load("res://Models/OBJ format/cutting-board.obj")
	if cutting_board_mesh:
		var board_inst = MeshInstance3D.new()
		board_inst.mesh = cutting_board_mesh
		
		# Material override to color it correctly
		var material = StandardMaterial3D.new()
		material.albedo_texture = colormap_tex
		board_inst.material_override = material
		
		# Center the board
		var aabb = cutting_board_mesh.get_aabb()
		var max_size = max(aabb.size.x, max(aabb.size.y, aabb.size.z))
		var target_scale = 1.8 / max_size
		board_inst.scale = Vector3(target_scale, target_scale, target_scale)
		board_inst.position = Vector3(0, -0.05, -0.2)
		
		kitchen_scene.add_child(board_inst)

	# Frying pans, pots, utensils, and other assets on sides, top and bottom
	var background_items = [
		# Left side: Frying pan, pot, spoons, shaker, bottles, cheese, bag, beet
		{"model": "res://Models/OBJ format/frying-pan.obj", "pos": Vector3(-1.8, 0.05, -0.4), "scale": 1.4, "rot": Vector3(0, 45, 0)},
		{"model": "res://Models/OBJ format/pot.obj", "pos": Vector3(-2.2, 0.1, 0.6), "scale": 1.4, "rot": Vector3(0, 0, 0)},
		{"model": "res://Models/OBJ format/cooking-knife.obj", "pos": Vector3(-1.2, 0.0, 0.8), "scale": 1.2, "rot": Vector3(0, -30, 0)},
		{"model": "res://Models/OBJ format/cooking-spoon.obj", "pos": Vector3(-1.0, 0.0, -0.8), "scale": 1.2, "rot": Vector3(0, 120, 0)},
		{"model": "res://Models/OBJ format/shaker-salt.obj", "pos": Vector3(-0.8, 0.0, -0.4), "scale": 0.8, "rot": Vector3(0, 0, 0)},
		{"model": "res://Models/OBJ format/bottle-oil.obj", "pos": Vector3(-2.5, 0.2, -0.2), "scale": 1.3, "rot": Vector3(0, -20, 0)},
		{"model": "res://Models/OBJ format/cheese.obj", "pos": Vector3(-1.5, 0.08, 0.2), "scale": 1.1, "rot": Vector3(0, 15, 0)},
		{"model": "res://Models/OBJ format/mortar.obj", "pos": Vector3(-2.4, 0.05, 1.2), "scale": 1.1, "rot": Vector3(0, 0, 0)},
		{"model": "res://Models/OBJ format/bottle-ketchup.obj", "pos": Vector3(-2.0, 0.15, -1.0), "scale": 1.0, "rot": Vector3(0, 10, 0)},
		{"model": "res://Models/OBJ format/cup-coffee.obj", "pos": Vector3(-1.4, 0.05, -1.2), "scale": 0.9, "rot": Vector3(0, -45, 0)},
		{"model": "res://Models/OBJ format/apple.obj", "pos": Vector3(-0.9, 0.05, 0.3), "scale": 0.7, "rot": Vector3(0, 0, 0)},
		{"model": "res://Models/OBJ format/avocado.obj", "pos": Vector3(-1.1, 0.05, 0.4), "scale": 0.7, "rot": Vector3(0, 35, 0)},
		{"model": "res://Models/OBJ format/bacon.obj", "pos": Vector3(-1.6, 0.05, 0.8), "scale": 0.8, "rot": Vector3(0, 45, 0)},
		{"model": "res://Models/OBJ format/bag.obj", "pos": Vector3(-2.8, 0.3, 0.4), "scale": 1.3, "rot": Vector3(0, 10, 0)},
		{"model": "res://Models/OBJ format/beet.obj", "pos": Vector3(-1.3, 0.05, 1.1), "scale": 0.8, "rot": Vector3(0, 0, 0)},
		{"model": "res://Models/OBJ format/cauliflower.obj", "pos": Vector3(-2.7, 0.1, -0.8), "scale": 1.0, "rot": Vector3(0, 0, 0)},

		# Right side: Plates, knives, forks, pans, pepper shaker, bread, tomato
		{"model": "res://Models/OBJ format/pan.obj", "pos": Vector3(1.8, 0.05, -0.4), "scale": 1.4, "rot": Vector3(0, -45, 0)},
		{"model": "res://Models/OBJ format/utensil-fork.obj", "pos": Vector3(1.1, 0.0, -0.8), "scale": 1.0, "rot": Vector3(0, -10, 0)},
		{"model": "res://Models/OBJ format/utensil-knife.obj", "pos": Vector3(1.3, 0.0, -0.8), "scale": 1.0, "rot": Vector3(0, 10, 0)},
		{"model": "res://Models/OBJ format/plate.obj", "pos": Vector3(2.2, 0.02, 0.6), "scale": 1.5, "rot": Vector3(0, 0, 0)},
		{"model": "res://Models/OBJ format/rollingPin.obj", "pos": Vector3(1.4, 0.05, 0.8), "scale": 1.2, "rot": Vector3(0, 75, 0)},
		{"model": "res://Models/OBJ format/shaker-pepper.obj", "pos": Vector3(0.8, 0.0, -0.4), "scale": 0.8, "rot": Vector3(0, 0, 0)},
		{"model": "res://Models/OBJ format/bread.obj", "pos": Vector3(1.6, 0.06, 0.1), "scale": 1.2, "rot": Vector3(0, -40, 0)},
		{"model": "res://Models/OBJ format/tomato.obj", "pos": Vector3(2.0, 0.05, -1.0), "scale": 0.9, "rot": Vector3(0, 0, 0)},
		{"model": "res://Models/OBJ format/knife-block.obj", "pos": Vector3(2.5, 0.25, -0.3), "scale": 1.5, "rot": Vector3(0, -90, 0)},
		{"model": "res://Models/OBJ format/bottle-musterd.obj", "pos": Vector3(2.2, 0.15, -0.8), "scale": 1.0, "rot": Vector3(0, -15, 0)},
		{"model": "res://Models/OBJ format/mug.obj", "pos": Vector3(1.5, 0.05, -1.2), "scale": 0.9, "rot": Vector3(0, 120, 0)},
		{"model": "res://Models/OBJ format/pepper-mill.obj", "pos": Vector3(2.4, 0.15, 1.2), "scale": 1.1, "rot": Vector3(0, 0, 0)},
		{"model": "res://Models/OBJ format/broccoli.obj", "pos": Vector3(1.0, 0.05, 0.3), "scale": 0.8, "rot": Vector3(0, 15, 0)},
		{"model": "res://Models/OBJ format/cabbage.obj", "pos": Vector3(1.7, 0.08, 1.0), "scale": 1.0, "rot": Vector3(0, 0, 0)},
		{"model": "res://Models/OBJ format/can-small.obj", "pos": Vector3(1.1, 0.05, -1.3), "scale": 0.8, "rot": Vector3(0, 20, 0)},
		{"model": "res://Models/OBJ format/cherries.obj", "pos": Vector3(1.9, 0.05, 0.2), "scale": 0.7, "rot": Vector3(0, -10, 0)},
		{"model": "res://Models/OBJ format/celery-stick.obj", "pos": Vector3(1.3, 0.05, 1.1), "scale": 0.8, "rot": Vector3(0, 0, 0)},

		# Top/Back background: Stew pots, steamer, barrel, tajine, pumpkin
		{"model": "res://Models/OBJ format/pot-stew.obj", "pos": Vector3(-0.9, 0.1, -1.6), "scale": 1.3, "rot": Vector3(0, 15, 0)},
		{"model": "res://Models/OBJ format/steamer.obj", "pos": Vector3(0.9, 0.1, -1.6), "scale": 1.3, "rot": Vector3(0, -15, 0)},
		{"model": "res://Models/OBJ format/barrel.obj", "pos": Vector3(-2.8, 0.4, -1.4), "scale": 1.6, "rot": Vector3(0, 0, 0)},
		{"model": "res://Models/OBJ format/tajine.obj", "pos": Vector3(2.8, 0.1, -1.4), "scale": 1.4, "rot": Vector3(0, 0, 0)},
		{"model": "res://Models/OBJ format/pumpkin.obj", "pos": Vector3(0.0, 0.1, -1.6), "scale": 1.2, "rot": Vector3(0, 45, 0)},
		{"model": "res://Models/OBJ format/can.obj", "pos": Vector3(-1.6, 0.05, -1.7), "scale": 0.9, "rot": Vector3(0, 0, 0)},
		{"model": "res://Models/OBJ format/bowl.obj", "pos": Vector3(-2.2, 0.05, -1.6), "scale": 1.1, "rot": Vector3(0, 0, 0)},
		{"model": "res://Models/OBJ format/cup-tea.obj", "pos": Vector3(2.2, 0.05, -1.6), "scale": 0.9, "rot": Vector3(0, -10, 0)},
		{"model": "res://Models/OBJ format/honey.obj", "pos": Vector3(-0.4, 0.1, -1.8), "scale": 0.8, "rot": Vector3(0, 0, 0)},
		{"model": "res://Models/OBJ format/peanut-butter.obj", "pos": Vector3(0.4, 0.1, -1.8), "scale": 0.8, "rot": Vector3(0, 0, 0)},

		# Bottom/Front foreground: Cooking spatula, whisk, lemon, carrot, onion, eggplant
		{"model": "res://Models/OBJ format/cooking-spatula.obj", "pos": Vector3(-0.5, 0.0, 1.2), "scale": 1.1, "rot": Vector3(0, 80, 0)},
		{"model": "res://Models/OBJ format/whisk.obj", "pos": Vector3(0.5, 0.0, 1.2), "scale": 1.1, "rot": Vector3(0, -80, 0)},
		{"model": "res://Models/OBJ format/lemon.obj", "pos": Vector3(-1.1, 0.05, 1.3), "scale": 0.7, "rot": Vector3(0, 20, 0)},
		{"model": "res://Models/OBJ format/carrot.obj", "pos": Vector3(-0.25, 0.05, 1.4), "scale": 0.8, "rot": Vector3(0, -10, 0)},
		{"model": "res://Models/OBJ format/onion.obj", "pos": Vector3(0.25, 0.05, 1.4), "scale": 0.7, "rot": Vector3(0, 10, 0)},
		{"model": "res://Models/OBJ format/eggplant.obj", "pos": Vector3(1.1, 0.05, 1.3), "scale": 0.9, "rot": Vector3(0, -25, 0)},
		{"model": "res://Models/OBJ format/fish.obj", "pos": Vector3(-0.6, 0.02, 1.5), "scale": 1.0, "rot": Vector3(0, 60, 0)},
		{"model": "res://Models/OBJ format/radish.obj", "pos": Vector3(0.6, 0.04, 1.5), "scale": 0.7, "rot": Vector3(0, -60, 0)},
		{"model": "res://Models/OBJ format/pear.obj", "pos": Vector3(-1.4, 0.05, 1.4), "scale": 0.7, "rot": Vector3(0, 0, 0)},
		{"model": "res://Models/OBJ format/banana.obj", "pos": Vector3(1.4, 0.05, 1.4), "scale": 0.8, "rot": Vector3(0, 30, 0)}
	]

	for item in background_items:
		var item_mesh = load(item["model"])
		if item_mesh:
			var inst = MeshInstance3D.new()
			inst.mesh = item_mesh
			
			var material = StandardMaterial3D.new()
			material.albedo_texture = colormap_tex
			inst.material_override = material
			
			var aabb = item_mesh.get_aabb()
			var max_size = max(aabb.size.x, max(aabb.size.y, aabb.size.z))
			var target_scale = item["scale"] / (max_size if max_size > 0.001 else 1.0)
			inst.scale = Vector3(target_scale, target_scale, target_scale)
			
			var offset_pivot = (-aabb.position - (aabb.size / 2.0)) * target_scale
			inst.position = item["pos"] + offset_pivot
			inst.rotation_degrees = item["rot"]
			
			kitchen_scene.add_child(inst)
