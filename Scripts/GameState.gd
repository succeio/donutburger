extends Node

signal time_changed(seconds_left: int)
signal game_over(score: int)
signal food_combined(food_id: String)
signal food_list_updated
signal level_changed(level: int, xp: int, xp_needed: int)
signal level_rewarded(food_id: String)
signal level_up_pending(options: Array)

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

# Upgrade database
var UPGRADES = {
	"time_limit": {
		"name": "UPGRADE_TIME_LIMIT_NAME",
		"desc": "UPGRADE_TIME_LIMIT_DESC"
	},
	"extra_craft": {
		"name": "UPGRADE_EXTRA_CRAFT_NAME",
		"desc": "UPGRADE_EXTRA_CRAFT_DESC"
	},
	"refund": {
		"name": "UPGRADE_REFUND_NAME",
		"desc": "UPGRADE_REFUND_DESC"
	},
	"xp_boost": {
		"name": "UPGRADE_XP_BOOST_NAME",
		"desc": "UPGRADE_XP_BOOST_DESC"
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
					inventory.append(commons[randi() % commons.size()])
					# Extra craft upgrade chance
					if randf() < extra_craft_chance:
						inventory.append(commons[randi() % commons.size()])
					
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
			inventory.append(commons[randi() % commons.size()])
			# Extra craft upgrade chance
			if randf() < extra_craft_chance:
				inventory.append(commons[randi() % commons.size()])
			
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
		inventory.append(rand_food)
		emit_signal("food_list_updated")
		emit_signal("level_rewarded", rand_food)
		AudioManager.play_sfx("res://Audio/confirmation_001.ogg", 3.0)
		
	# Select 3 random unique upgrades from the list
	var keys = UPGRADES.keys()
	keys.shuffle()
	var selected_upgrades = [keys[0], keys[1], keys[2]]
	
	# Pause game timer while selecting upgrade
	var timer = get_node_or_null("GameTimer")
	if timer:
		timer.paused = true
		
	emit_signal("level_up_pending", selected_upgrades)
