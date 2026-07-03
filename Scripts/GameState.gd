extends Node

signal time_changed(seconds_left: int)
signal game_over(score: int)
signal food_combined(food_id: String)
signal food_list_updated
signal level_changed(level: int, xp: int, xp_needed: int)
signal level_rewarded(food_id: String)
signal level_up_pending(options: Array)
signal upgrades_updated(active_upgrades: Dictionary)

var time_limit: int = 60
var time_left: int = 60
var score: int = 0
var game_active: bool = false
var current_level: int = 1
var current_xp: int = 0
var xp_needed: int = 30 # Levels are gained much faster now

# Upgrade system state
var extra_craft_chance: float = 0.0 # Chance to get an extra common ingredient during craft/upgrade
var refund_chance: float = 0.0 # Chance to refund one of the spent ingredients
var xp_multiplier: float = 1.0 # XP Gain multiplier
var quality_upgrade_chance: float = 0.0 # Chance to upgrade ingredient rarity by +1 tier when rolling/receiving reward
var auto_combine_enabled: bool = false
var active_upgrades: Dictionary = {} # Stores upgrade_key -> level/count

# Upgrade database with rarities
var UPGRADES = {
	"time_limit": {
		"name": "UPGRADE_TIME_LIMIT_NAME",
		"desc": "UPGRADE_TIME_LIMIT_DESC",
		"rarity": DataManager.Rarity.COMMON
	},
	"extra_craft": {
		"name": "UPGRADE_EXTRA_CRAFT_NAME",
		"desc": "UPGRADE_EXTRA_CRAFT_DESC",
		"rarity": DataManager.Rarity.RARE
	},
	"refund": {
		"name": "UPGRADE_REFUND_NAME",
		"desc": "UPGRADE_REFUND_DESC",
		"rarity": DataManager.Rarity.RARE
	},
	"xp_boost": {
		"name": "UPGRADE_XP_BOOST_NAME",
		"desc": "UPGRADE_XP_BOOST_DESC",
		"rarity": DataManager.Rarity.COMMON
	},
	"quality_up": {
		"name": "UPGRADE_QUALITY_UP_NAME",
		"desc": "UPGRADE_QUALITY_UP_DESC",
		"rarity": DataManager.Rarity.UNIQUE
	},
	"auto_combine": {
		"name": "UPGRADE_AUTO_COMBINE_NAME",
		"desc": "UPGRADE_AUTO_COMBINE_DESC",
		"rarity": DataManager.Rarity.LEGENDARY
	}
}

# Array of active food IDs currently owned by the user
var inventory: Array = []

func start_game() -> void:
	# Clear old timer if any exists
	var old_timer = get_node_or_null("GameTimer")
	if old_timer:
		old_timer.queue_free()
		
	score = 0
	time_left = time_limit
	inventory.clear()
	current_level = 1
	current_xp = 0
	xp_needed = 30
	extra_craft_chance = 0.0
	refund_chance = 0.0
	xp_multiplier = 1.0
	quality_upgrade_chance = 0.0
	auto_combine_enabled = false
	active_upgrades.clear()
	emit_signal("upgrades_updated", active_upgrades)
	emit_signal("level_changed", current_level, current_xp, xp_needed)
	
	# Give starting common products
	var commons = []
	for id in DataManager.foods:
		if DataManager.foods[id]["rarity"] == DataManager.Rarity.COMMON:
			commons.append(id)
			
	# Start with 12 random commons (larger starting pool)
	for i in range(12):
		var rand_food = commons[randi() % commons.size()]
		inventory.append(rand_food)
		
	game_active = true
	emit_signal("food_list_updated")
	emit_signal("time_changed", time_left)
	
	# Start timer
	var timer = Timer.new()
	timer.name = "GameTimer"
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func _on_timer_timeout() -> void:
	if not game_active:
		return
		
	# Handle auto combine if perk is active - combine at most ONE recipe per second to show step-by-step cooking
	if auto_combine_enabled:
		var inv_size = inventory.size()
		var combined = false
		for i in range(inv_size):
			for j in range(i + 1, inv_size):
				# Try combining identical tier upgrade (3x) first
				var item1 = inventory[i]
				var item2 = inventory[j]
				if item1 == item2:
					var identical_indices = []
					for k in range(inventory.size()):
						if inventory[k] == item1:
							identical_indices.append(k)
					if identical_indices.size() >= 3:
						combine_items(identical_indices[0], identical_indices[1])
						combined = true
						emit_signal("food_list_updated")
						break
				
				# Try recipe combo
				var result = DataManager.find_recipe(item1, item2)
				if result != "":
					combine_items(i, j)
					combined = true
					emit_signal("food_list_updated")
					break
			if combined:
				break
					
	time_left -= 1
	emit_signal("time_changed", time_left)
	if time_left <= 0:
		end_game()

func end_game() -> void:
	game_active = false
	var timer = get_node_or_null("GameTimer")
	if timer:
		timer.queue_free()
		
	# Calculate total score from inventory
	score = 0
	for food_id in inventory:
		var rarity = DataManager.foods[food_id]["rarity"]
		score += DataManager.RARITY_INFO[rarity]["value"]
		
	emit_signal("game_over", score)

# Roll / Buy a random ingredient for time penalty
func roll_ingredient() -> bool:
	if not game_active:
		return false
		
	# Find a random common product to add
	var commons = []
	for id in DataManager.foods:
		if DataManager.foods[id]["rarity"] == DataManager.Rarity.COMMON:
			commons.append(id)
			
	if commons.size() == 0:
		return false
		
	var rand_food = commons[randi() % commons.size()]
	inventory.append(rand_food)
	time_left = max(0, time_left - 5)
	emit_signal("time_changed", time_left)
	emit_signal("food_list_updated")
	
	if time_left <= 0:
		end_game()
	return true

func get_upgraded_food(food_id: String) -> String:
	if not DataManager.foods.has(food_id):
		return food_id
	var current_rarity = DataManager.foods[food_id]["rarity"]
	if current_rarity == DataManager.Rarity.LEGENDARY:
		return food_id
		
	var next_rarity = current_rarity + 1
	var candidates = []
	for fid in DataManager.foods:
		# Filter only items of the exact next rarity
		if DataManager.foods[fid]["rarity"] == next_rarity:
			candidates.append(fid)
			
	if candidates.size() > 0:
		return candidates[randi() % candidates.size()]
	return food_id

# Combine two items by index in inventory
func combine_items(idx1: int, idx2: int) -> bool:
	if idx1 == idx2 or idx1 < 0 or idx2 < 0 or idx1 >= inventory.size() or idx2 >= inventory.size():
		return false
		
	var item1 = inventory[idx1]
	var item2 = inventory[idx2]
	
	# Check if they are identical. If so, check if we have a third identical item in inventory.
	if item1 == item2:
		var identical_indices = []
		for i in range(inventory.size()):
			if inventory[i] == item1:
				identical_indices.append(i)
		
		# If we have 3 or more of this identical item, combine them into 1 item of the next tier
		if identical_indices.size() >= 3:
			var upgrade_result = DataManager.get_next_tier_food(item1)
			if upgrade_result != "":
				# Sort indices descending to safely remove them from the array
				identical_indices.sort()
				identical_indices.reverse()
				
				# Remove the first 3 identical items
				var spent = []
				for j in range(3):
					spent.append(inventory[identical_indices[j]])
					inventory.remove_at(identical_indices[j])
				
				inventory.append(upgrade_result)
				
				# Successful upgrade bonus: +10 seconds, +1 free common ingredient
				time_left = min(time_limit, time_left + 10)
				emit_signal("time_changed", time_left)
				
				# Refund chance
				if randf() < refund_chance and spent.size() > 0:
					inventory.append(spent[randi() % spent.size()])
				
				var commons = []
				for id in DataManager.foods:
					if DataManager.foods[id]["rarity"] == DataManager.Rarity.COMMON:
						commons.append(id)
				if commons.size() > 0:
					var bonus_item = commons[randi() % commons.size()]
					inventory.append(bonus_item)
					
					# Extra craft upgrade chance
					if randf() < extra_craft_chance:
						var extra_bonus = commons[randi() % commons.size()]
						inventory.append(extra_bonus)
					
				AudioManager.play_sfx("res://Audio/confirmation_001.ogg", 3.0)
				
				# Gain XP
				var xp_reward = get_xp_for_food(upgrade_result) * xp_multiplier
				gain_xp(int(xp_reward))
				
				# Notify UI which item was created
				emit_signal("food_list_updated")
				emit_signal("food_combined", upgrade_result)
				return true
				
	var result = DataManager.find_recipe(item1, item2)
	
	if result != "":
		# Add combined result FIRST, so index removals don't break or access out of bounds
		# Remove larger index first to keep lower index valid, then remove lower index.
		var first = max(idx1, idx2)
		var second = min(idx1, idx2)
		var spent = [inventory[first], inventory[second]]
		inventory.remove_at(first)
		inventory.remove_at(second)
		
		inventory.append(result)
		
		# Successful recipe combine bonus: +10 seconds, +1 free common ingredient
		time_left = min(time_limit, time_left + 10)
		emit_signal("time_changed", time_left)
		
		# Refund chance
		if randf() < refund_chance and spent.size() > 0:
			inventory.append(spent[randi() % spent.size()])
		
		var commons = []
		for id in DataManager.foods:
			if DataManager.foods[id]["rarity"] == DataManager.Rarity.COMMON:
				commons.append(id)
		if commons.size() > 0:
			var bonus_item = commons[randi() % commons.size()]
			inventory.append(bonus_item)
			
			# Extra craft upgrade chance
			if randf() < extra_craft_chance:
				var extra_bonus = commons[randi() % commons.size()]
				inventory.append(extra_bonus)
			
		AudioManager.play_sfx("res://Audio/confirmation_002.ogg", 3.0)
		
		# Gain XP
		var xp_reward = get_xp_for_food(result) * xp_multiplier
		gain_xp(int(xp_reward))
		
		# Notify UI which item was created
		emit_signal("food_list_updated")
		emit_signal("food_combined", result)
		return true
		
	return false

func get_xp_for_food(food_id: String) -> int:
	if not DataManager.foods.has(food_id):
		return 0
	var rarity = DataManager.foods[food_id]["rarity"]
	match rarity:
		DataManager.Rarity.COMMON: return 10
		DataManager.Rarity.RARE: return 25
		DataManager.Rarity.UNIQUE: return 50
		DataManager.Rarity.EPIC: return 100
		DataManager.Rarity.LEGENDARY: return 200
	return 0

func get_xp_needed_for_level(lvl: int) -> int:
	return 30 + (lvl - 1) * 15

func gain_xp(amount: int) -> void:
	if not game_active:
		return
	current_xp += amount
	while current_xp >= xp_needed:
		current_xp -= xp_needed
		current_level += 1
		xp_needed = get_xp_needed_for_level(current_level)
		_on_level_up()
	emit_signal("level_changed", current_level, current_xp, xp_needed)

func select_upgrade(upgrade_key: String) -> void:
	active_upgrades[upgrade_key] = active_upgrades.get(upgrade_key, 0) + 1
	emit_signal("upgrades_updated", active_upgrades)
	
	match upgrade_key:
		"time_limit":
			time_limit += 10
			time_left = min(time_limit, time_left + 15)
			emit_signal("time_changed", time_left)
		"extra_craft":
			extra_craft_chance += 0.20
		"refund":
			refund_chance += 0.15
		"xp_boost":
			xp_multiplier += 0.30
		"quality_up":
			quality_upgrade_chance += 0.15
		"auto_combine":
			auto_combine_enabled = true
			
	# Resume game time
	var timer = get_node_or_null("GameTimer")
	if timer:
		timer.paused = false

func _on_level_up() -> void:
	# Add a random common ingredient
	var commons = []
	for id in DataManager.foods:
		if DataManager.foods[id]["rarity"] == DataManager.Rarity.COMMON:
			commons.append(id)
	if commons.size() > 0:
		var rand_food = commons[randi() % commons.size()]
		if randf() < quality_upgrade_chance:
			rand_food = get_upgraded_food(rand_food)
		inventory.append(rand_food)
		emit_signal("food_list_updated")
		emit_signal("level_rewarded", rand_food)
		AudioManager.play_sfx("res://Audio/confirmation_001.ogg", 3.0)
		
	# Select upgrade options based on rarity chances
	# legendary: 1%, unique: 9%, rare: 30%, common: 60%
	var candidates = []
	for k in UPGRADES:
		if k == "auto_combine" and auto_combine_enabled:
			continue
		candidates.append(k)
		
	var selected_upgrades = []
	# Roll 3 times to get 3 unique options
	while selected_upgrades.size() < min(3, candidates.size()):
		var roll = randf()
		var target_rarity = DataManager.Rarity.COMMON
		if roll < 0.01:
			target_rarity = DataManager.Rarity.LEGENDARY
		elif roll < 0.10:
			target_rarity = DataManager.Rarity.UNIQUE
		elif roll < 0.40:
			target_rarity = DataManager.Rarity.RARE
		else:
			target_rarity = DataManager.Rarity.COMMON
			
		# Find upgrades matching rolled rarity
		var matching = []
		for c in candidates:
			if c in selected_upgrades:
				continue
			if UPGRADES[c]["rarity"] == target_rarity:
				matching.append(c)
				
		# Fallback if no upgrades match this rarity or they are already chosen
		if matching.size() == 0:
			var any_available = []
			for c in candidates:
				if not c in selected_upgrades:
					any_available.append(c)
			if any_available.size() > 0:
				selected_upgrades.append(any_available[randi() % any_available.size()])
			else:
				break
		else:
			selected_upgrades.append(matching[randi() % matching.size()])
	
	# Pause game timer while selecting upgrade
	var timer = get_node_or_null("GameTimer")
	if timer:
		timer.paused = true
		
	emit_signal("level_up_pending", selected_upgrades)
