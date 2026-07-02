extends Node3D

@onready var recipe_list = $UI/MainLayout/LeftPanel/VBox/Scroll/RecipeList
@onready var inventory_grid = $UI/MainLayout/RightPanel/VBox/Scroll/InventoryGrid
@onready var time_label = $UI/MainLayout/RightPanel/VBox/StatusContainer/TimeLabel
@onready var roll_button = $UI/MainLayout/RightPanel/VBox/BottomControls/RollButton
@onready var game_over_overlay = $UI/GameOverOverlay
@onready var score_label = $UI/GameOverOverlay/VBox/ScoreLabel
@onready var restart_button = $UI/GameOverOverlay/VBox/RestartButton
@onready var food_pivot = $FoodPivot

var selected_inventory_index: int = -1
var food_3d_node: Node3D = null

func _ready() -> void:
	GameState.time_changed.connect(_on_time_changed)
	GameState.game_over.connect(_on_game_over)
	GameState.food_list_updated.connect(_update_ui)
	
	roll_button.pressed.connect(_on_roll_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	
	GameState.start_game()

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
		
		# Draw "3x [Food]"
		var label_3x = Label.new()
		label_3x.text = "3x "
		label_3x.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label_3x.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		var in_rect = TextureRect.new()
		in_rect.custom_minimum_size = Vector2(40, 40)
		in_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		in_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		in_rect.texture = load(food_data["preview"])
		in_rect.tooltip_text = food_data["name"]
		
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
		out_rect.tooltip_text = out_data["name"] + " (Random next-tier)"
		
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
		in1_rect.tooltip_text = in1_data["name"]
		
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
		in2_rect.tooltip_text = in2_data["name"]
		
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
		out_rect.tooltip_text = out_data["name"]
		
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
		empty_label.text = "No combinations available\nwith current ingredients."
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
		button.tooltip_text = "%s (%s)\nScore Value: %d" % [
			food_data["name"],
			DataManager.RARITY_INFO[food_data["rarity"]]["name"],
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
		
		# Set material with colormap texture. Models in this pack use colormap.png
		var material = StandardMaterial3D.new()
		var texture = load("res://Models/OBJ format/Textures/colormap.png")
		if texture:
			material.albedo_texture = texture
			material.roughness = 0.8
		mesh_instance.material_override = material
		
		food_pivot.add_child(mesh_instance)
		food_3d_node = mesh_instance
		
		mesh_instance.scale = Vector3(12, 12, 12)
		mesh_instance.rotation_degrees = Vector3(15, 0, 0)

func _clear_3d_food() -> void:
	if food_3d_node and is_instance_valid(food_3d_node):
		food_3d_node.queue_free()
	food_3d_node = null

func _process(delta: float) -> void:
	if food_3d_node and is_instance_valid(food_3d_node):
		food_3d_node.rotate_y(delta * 1.0)

func _on_time_changed(seconds: int) -> void:
	time_label.text = "Time: %ds" % seconds
	if seconds <= 10:
		time_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	else:
		time_label.remove_theme_color_override("font_color")

func _on_game_over(score: int) -> void:
	score_label.text = "Final Culinary Score: %d" % score
	game_over_overlay.visible = true

func _on_roll_pressed() -> void:
	if not GameState.game_active:
		return
		
	# Find a random common product to add
	var commons = []
	for id in DataManager.foods:
		if DataManager.foods[id]["rarity"] == DataManager.Rarity.COMMON:
			commons.append(id)
			
	var rand_food = commons[randi() % commons.size()]
	GameState.inventory.append(rand_food)
	GameState.time_left = max(0, GameState.time_left - 5)
	GameState.emit_signal("time_changed", GameState.time_left)
	AudioManager.play_sfx("res://Audio/switch_001.ogg")
	GameState.emit_signal("food_list_updated")
	
	if GameState.time_left <= 0:
		GameState.end_game()

func _on_restart_pressed() -> void:
	AudioManager.play_sfx("res://Audio/maximize_001.ogg")
	game_over_overlay.visible = false
	GameState.start_game()
