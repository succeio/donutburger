extends Node

enum Rarity {
	COMMON,
	RARE,
	UNIQUE,
	EPIC,
	LEGENDARY
}

const RARITY_INFO = {
	Rarity.COMMON: {
		"name": "RARITY_COMMON",
		"color": Color(0.8, 0.8, 0.8),
		"value": 10
	},
	Rarity.RARE: {
		"name": "RARITY_RARE",
		"color": Color(0.1, 0.8, 0.1),
		"value": 50
	},
	Rarity.UNIQUE: {
		"name": "RARITY_UNIQUE",
		"color": Color(0.1, 0.5, 0.9),
		"value": 250
	},
	Rarity.EPIC: {
		"name": "RARITY_EPIC",
		"color": Color(0.6, 0.1, 0.9),
		"value": 1200
	},
	Rarity.LEGENDARY: {
		"name": "RARITY_LEGENDARY",
		"color": Color(0.9, 0.6, 0.0),
		"value": 6000
	}
}

var foods = {
	# COMMON
	"apple": {
		"name": "FOOD_apple",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/apple.png",
		"model": "res://Models/OBJ format/apple.obj"
	},
	"banana": {
		"name": "FOOD_banana",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/banana.png",
		"model": "res://Models/OBJ format/banana.obj"
	},
	"orange": {
		"name": "FOOD_orange",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/orange.png",
		"model": "res://Models/OBJ format/orange.obj"
	},
	"strawberry": {
		"name": "FOOD_strawberry",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/strawberry.png",
		"model": "res://Models/OBJ format/strawberry.obj"
	},
	"bread": {
		"name": "FOOD_bread",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/bread.png",
		"model": "res://Models/OBJ format/bread.obj"
	},
	"cheese": {
		"name": "FOOD_cheese",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/cheese.png",
		"model": "res://Models/OBJ format/cheese.obj"
	},
	"tomato": {
		"name": "FOOD_tomato",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/tomato.png",
		"model": "res://Models/OBJ format/tomato.obj"
	},
	"bacon": {
		"name": "FOOD_bacon",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/bacon.png",
		"model": "res://Models/OBJ format/bacon.obj"
	},
	"egg": {
		"name": "FOOD_egg",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/egg.png",
		"model": "res://Models/OBJ format/egg.obj"
	},
	"soda-can": {
		"name": "FOOD_soda_can",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/soda-can.png",
		"model": "res://Models/OBJ format/soda-can.obj"
	},
	"mushroom": {
		"name": "FOOD_mushroom",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/mushroom.png",
		"model": "res://Models/OBJ format/mushroom.obj"
	},
	"carrot": {
		"name": "FOOD_carrot",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/carrot.png",
		"model": "res://Models/OBJ format/carrot.obj"
	},
	"watermelon": {
		"name": "FOOD_watermelon",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/watermelon.png",
		"model": "res://Models/OBJ format/watermelon.obj"
	},
	"coconut": {
		"name": "FOOD_coconut",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/coconut.png",
		"model": "res://Models/OBJ format/coconut.obj"
	},
	"hot-dog-raw": {
		"name": "FOOD_hot_dog_raw",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/hot-dog-raw.png",
		"model": "res://Models/OBJ format/hot-dog-raw.obj"
	},

	# RARE
	"salad": {
		"name": "FOOD_salad",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/salad.png",
		"model": "res://Models/OBJ format/salad.obj"
	},
	"sandwich": {
		"name": "FOOD_sandwich",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/sandwich.png",
		"model": "res://Models/OBJ format/sandwich.obj"
	},
	"egg-cooked": {
		"name": "FOOD_egg_cooked",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/egg-cooked.png",
		"model": "res://Models/OBJ format/egg-cooked.obj"
	},
	"fries": {
		"name": "FOOD_fries",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/fries.png",
		"model": "res://Models/OBJ format/fries.obj"
	},
	"donut": {
		"name": "FOOD_donut",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/donut.png",
		"model": "res://Models/OBJ format/donut.obj"
	},
	"cookie": {
		"name": "FOOD_cookie",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/cookie.png",
		"model": "res://Models/OBJ format/cookie.obj"
	},
	"cup-coffee": {
		"name": "FOOD_cup_coffee",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/cup-coffee.png",
		"model": "res://Models/OBJ format/cup-coffee.obj"
	},
	"taco": {
		"name": "FOOD_taco",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/taco.png",
		"model": "res://Models/OBJ format/taco.obj"
	},
	"hot-dog": {
		"name": "FOOD_hot_dog",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/hot-dog.png",
		"model": "res://Models/OBJ format/hot-dog.obj"
	},

	# UNIQUE
	"burger": {
		"name": "FOOD_burger",
		"rarity": Rarity.UNIQUE,
		"preview": "res://Previews/burger.png",
		"model": "res://Models/OBJ format/burger.obj"
	},
	"pizza": {
		"name": "FOOD_pizza",
		"rarity": Rarity.UNIQUE,
		"preview": "res://Previews/pizza.png",
		"model": "res://Models/OBJ format/pizza.obj"
	},
	"pie": {
		"name": "FOOD_pie",
		"rarity": Rarity.UNIQUE,
		"preview": "res://Previews/pie.png",
		"model": "res://Models/OBJ format/pie.obj"
	},

	# EPIC
	"icecream": {
		"name": "FOOD_icecream",
		"rarity": Rarity.EPIC,
		"preview": "res://Previews/ice-cream.png",
		"model": "res://Models/OBJ format/ice-cream.obj"
	},
	"cake": {
		"name": "FOOD_cake",
		"rarity": Rarity.EPIC,
		"preview": "res://Previews/cake.png",
		"model": "res://Models/OBJ format/cake.obj"
	},
	"chef-special": {
		"name": "FOOD_chef_special",
		"rarity": Rarity.EPIC,
		"preview": "res://Previews/sushi-salmon.png",
		"model": "res://Models/OBJ format/sushi-salmon.obj"
	},

	# LEGENDARY
	"royal-burger": {
		"name": "FOOD_royal_burger",
		"rarity": Rarity.LEGENDARY,
		"preview": "res://Previews/burger-cheese-double.png",
		"model": "res://Models/OBJ format/burger-cheese-double.obj"
	},
	"mega-feast": {
		"name": "FOOD_mega_feast",
		"rarity": Rarity.LEGENDARY,
		"preview": "res://Previews/turkey.png",
		"model": "res://Models/OBJ format/turkey.obj"
	},
	"elixir": {
		"name": "FOOD_elixir",
		"rarity": Rarity.LEGENDARY,
		"preview": "res://Previews/wine-red.png",
		"model": "res://Models/OBJ format/wine-red.obj"
	},
	"ambrosia": {
		"name": "FOOD_ambrosia",
		"rarity": Rarity.LEGENDARY,
		"preview": "res://Previews/cake-birthday.png",
		"model": "res://Models/OBJ format/cake-birthday.obj"
	}
}

var recipes = [] # Parsed recipes for quick iteration

const RECIPES_DICT = {
	# RARE
	"salad": ["apple", "banana"],
	"sandwich": ["bread", "cheese"],
	"egg-cooked": ["egg", "bacon"],
	"fries": ["tomato", "carrot"],
	"donut": ["strawberry", "coconut"],
	"cookie": ["egg", "coconut"],
	"cup-coffee": ["soda-can", "mushroom"],
	"taco": ["cheese", "tomato"],
	"hot-dog": ["hot-dog-raw", "bread"],

	# UNIQUE
	"burger": ["sandwich", "egg-cooked"],
	"pizza": ["cheese", "bread"],
	"pie": ["apple", "bread"],

	# EPIC
	"icecream": ["salad", "donut"],
	"cake": ["cookie", "cup-coffee"],
	"chef-special": ["taco", "fries"],

	# LEGENDARY
	"royal-burger": ["burger", "pizza"],
	"mega-feast": ["pie", "chef-special"],
	"elixir": ["cake", "icecream"],
	"ambrosia": ["royal-burger", "mega-feast"]
}

func _ready() -> void:
	# Parse RECIPES dictionary into array format: [{"inputs": [in1, in2], "output": out}]
	for output in RECIPES_DICT:
		var inputs = RECIPES_DICT[output]
		recipes.append({
			"inputs": inputs,
			"output": output
		})

func get_next_tier_food(food_id: String) -> String:
	if not foods.has(food_id):
		return ""
	var current_rarity = foods[food_id]["rarity"]
	if current_rarity == Rarity.LEGENDARY:
		return "" # Already max tier
		
	var next_rarity = current_rarity + 1
	var candidates = []
	for fid in foods:
		if foods[fid]["rarity"] == next_rarity:
			candidates.append(fid)
			
	if candidates.size() > 0:
		return candidates[randi() % candidates.size()]
	return ""

func find_recipe(in1: String, in2: String) -> String:
	for out in RECIPES_DICT:
		var inputs = RECIPES_DICT[out]
		if (inputs[0] == in1 and inputs[1] == in2) or (inputs[0] == in2 and inputs[1] == in1):
			return out
	return ""
