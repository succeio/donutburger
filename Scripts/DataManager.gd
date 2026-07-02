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
	# ===================== COMMON INGREDIENTS =====================
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
	"bacon-raw": {
		"name": "FOOD_bacon_raw",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/bacon-raw.png",
		"model": "res://Models/OBJ format/bacon-raw.obj"
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
	"meat-raw": {
		"name": "FOOD_meat_raw",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/meat-raw.png",
		"model": "res://Models/OBJ format/meat-raw.obj"
	},
	"cabbage": {
		"name": "FOOD_cabbage",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/cabbage.png",
		"model": "res://Models/OBJ format/cabbage.obj"
	},
	"avocado": {
		"name": "FOOD_avocado",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/avocado.png",
		"model": "res://Models/OBJ format/avocado.obj"
	},
	"onion": {
		"name": "FOOD_onion",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/onion.png",
		"model": "res://Models/OBJ format/onion.obj"
	},
	"fish": {
		"name": "FOOD_fish",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/fish.png",
		"model": "res://Models/OBJ format/fish.obj"
	},
	"chocolate": {
		"name": "FOOD_chocolate",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/chocolate.png",
		"model": "res://Models/OBJ format/chocolate.obj"
	},
	"milk-carton": {
		"name": "FOOD_milk_carton",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/carton.png",
		"model": "res://Models/OBJ format/carton.obj"
	},

	# ===================== RARE PREPARED INGREDIENTS =====================
	"bacon-cooked": {
		"name": "FOOD_bacon_cooked",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/bacon.png",
		"model": "res://Models/OBJ format/bacon.obj"
	},
	"egg-cooked": {
		"name": "FOOD_egg_cooked",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/egg-cooked.png",
		"model": "res://Models/OBJ format/egg-cooked.obj"
	},
	"meat-patty": {
		"name": "FOOD_meat_patty",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/meat-patty.png",
		"model": "res://Models/OBJ format/meat-patty.obj"
	},
	"ketchup": {
		"name": "FOOD_ketchup",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/bottle-ketchup.png",
		"model": "res://Models/OBJ format/bottle-ketchup.obj"
	},
	"mustard": {
		"name": "FOOD_mustard",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/bottle-musterd.png",
		"model": "res://Models/OBJ format/bottle-musterd.obj"
	},
	"hot-dog-cooked": {
		"name": "FOOD_hot_dog_cooked",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/hot-dog.png",
		"model": "res://Models/OBJ format/hot-dog.obj"
	},
	"french-fries": {
		"name": "FOOD_french_fries",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/fries.png",
		"model": "res://Models/OBJ format/fries.obj"
	},
	"salad-fresh": {
		"name": "FOOD_salad_fresh",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/salad.png",
		"model": "res://Models/OBJ format/salad.obj"
	},
	"sandwich-simple": {
		"name": "FOOD_sandwich_simple",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/sandwich.png",
		"model": "res://Models/OBJ format/sandwich.obj"
	},
	"donut-simple": {
		"name": "FOOD_donut_simple",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/donut.png",
		"model": "res://Models/OBJ format/donut.obj"
	},
	"cookie-simple": {
		"name": "FOOD_cookie_simple",
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
	"juice-orange": {
		"name": "FOOD_juice_orange",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/soda.png",
		"model": "res://Models/OBJ format/soda.obj"
	},
	"coconut-milk": {
		"name": "FOOD_coconut_milk",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/coconut-half.png",
		"model": "res://Models/OBJ format/coconut-half.obj"
	},
	"fish-cooked": {
		"name": "FOOD_fish_cooked",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/meat-cooked.png",
		"model": "res://Models/OBJ format/meat-cooked.obj"
	},

	# ===================== UNIQUE MEALS =====================
	"burger-simple": {
		"name": "FOOD_burger_simple",
		"rarity": Rarity.UNIQUE,
		"preview": "res://Previews/burger.png",
		"model": "res://Models/OBJ format/burger.obj"
	},
	"hot-dog-complete": {
		"name": "FOOD_hot_dog_complete",
		"rarity": Rarity.UNIQUE,
		"preview": "res://Previews/corn-dog.png",
		"model": "res://Models/OBJ format/corn-dog.obj"
	},
	"taco-beef": {
		"name": "FOOD_taco_beef",
		"rarity": Rarity.UNIQUE,
		"preview": "res://Previews/taco.png",
		"model": "res://Models/OBJ format/taco.obj"
	},
	"pizza-margherita": {
		"name": "FOOD_pizza_margherita",
		"rarity": Rarity.UNIQUE,
		"preview": "res://Previews/pizza.png",
		"model": "res://Models/OBJ format/pizza.obj"
	},
	"pie-apple": {
		"name": "FOOD_pie_apple",
		"rarity": Rarity.UNIQUE,
		"preview": "res://Previews/pie.png",
		"model": "res://Models/OBJ format/pie.obj"
	},
	"sushi-roll": {
		"name": "FOOD_sushi_roll",
		"rarity": Rarity.UNIQUE,
		"preview": "res://Previews/rice-ball.png",
		"model": "res://Models/OBJ format/rice-ball.obj"
	},
	"chocolate-shake": {
		"name": "FOOD_chocolate_shake",
		"rarity": Rarity.UNIQUE,
		"preview": "res://Previews/frappe.png",
		"model": "res://Models/OBJ format/frappe.obj"
	},
	"sub-sandwich": {
		"name": "FOOD_sub_sandwich",
		"rarity": Rarity.UNIQUE,
		"preview": "res://Previews/sub.png",
		"model": "res://Models/OBJ format/sub.obj"
	},

	# ===================== EPIC DISHES =====================
	"burger-cheese-double": {
		"name": "FOOD_burger_cheese_double",
		"rarity": Rarity.EPIC,
		"preview": "res://Previews/burger-cheese.png",
		"model": "res://Models/OBJ format/burger-cheese.obj"
	},
	"icecream-sundae": {
		"name": "FOOD_icecream_sundae",
		"rarity": Rarity.EPIC,
		"preview": "res://Previews/sundae.png",
		"model": "res://Models/OBJ format/sundae.obj"
	},
	"cake-chocolate": {
		"name": "FOOD_cake_chocolate",
		"rarity": Rarity.EPIC,
		"preview": "res://Previews/cake.png",
		"model": "res://Models/OBJ format/cake.obj"
	},
	"sushi-deluxe": {
		"name": "FOOD_sushi_deluxe",
		"rarity": Rarity.EPIC,
		"preview": "res://Previews/sushi-salmon.png",
		"model": "res://Models/OBJ format/sushi-salmon.obj"
	},
	"stew-hearty": {
		"name": "FOOD_stew_hearty",
		"rarity": Rarity.EPIC,
		"preview": "res://Previews/bowl-soup.png",
		"model": "res://Models/OBJ format/bowl-soup.obj"
	},

	# ===================== LEGENDARY FEASTS =====================
	"royal-feast-burger": {
		"name": "FOOD_royal_feast_burger",
		"rarity": Rarity.LEGENDARY,
		"preview": "res://Previews/burger-cheese-double.png",
		"model": "res://Models/OBJ format/burger-cheese-double.obj"
	},
	"mega-turkey-dinner": {
		"name": "FOOD_mega_turkey_dinner",
		"rarity": Rarity.LEGENDARY,
		"preview": "res://Previews/turkey.png",
		"model": "res://Models/OBJ format/turkey.obj"
	},
	"elixir-red": {
		"name": "FOOD_elixir_red",
		"rarity": Rarity.LEGENDARY,
		"preview": "res://Previews/wine-red.png",
		"model": "res://Models/OBJ format/wine-red.obj"
	},
	"ambrosia-cake": {
		"name": "FOOD_ambrosia_cake",
		"rarity": Rarity.LEGENDARY,
		"preview": "res://Previews/cake-birthday.png",
		"model": "res://Models/OBJ format/cake-birthday.obj"
	}
}

var recipes = [] # Parsed recipes for quick iteration

const RECIPES_DICT = {
	# ===================== RARE PREPARATIONS (Common + Common) =====================
	"bacon-cooked": ["bacon-raw", "egg"], # Raw bacon cooked with egg flavor
	"egg-cooked": ["egg", "onion"], # Egg scrambled with onion
	"meat-patty": ["meat-raw", "onion"], # Burger meat patty made from raw meat + onion
	"ketchup": ["tomato", "orange"], # Sweet tomato sauce
	"mustard": ["carrot", "soda-can"], # Tangy carrot mustard mix
	"hot-dog-cooked": ["hot-dog-raw", "bread"], # Simple cooked hot dog on bun
	"french-fries": ["carrot", "tomato"], # Potato slice equivalent (using tomato + carrot mix)
	"salad-fresh": ["cabbage", "tomato"], # Fresh healthy salad
	"sandwich-simple": ["bread", "cheese"], # Standard cheese sandwich
	"donut-simple": ["strawberry", "coconut"], # Strawberry coconut glazed donut
	"cookie-simple": ["chocolate", "milk-carton"], # Chocolate chip cookies
	"juice-orange": ["orange", "watermelon"], # Refreshing fruit blend
	"coconut-milk": ["coconut", "milk-carton"], # Fresh coconut milk extract
	"fish-cooked": ["fish", "mushroom"], # Grilled mushroom fish

	# ===================== UNIQUE MEALS (Rare + Rare / Rare + Common) =====================
	"burger-simple": ["meat-patty", "ketchup"], # Beef patty with ketchup
	"hot-dog-complete": ["hot-dog-cooked", "mustard"], # Hot dog dressed with mustard
	"taco-beef": ["salad-fresh", "meat-patty"], # Taco filled with fresh salad and meat
	"pizza-margherita": ["sandwich-simple", "ketchup"], # Pizza base (bread/cheese) + sweet tomato ketchup
	"pie-apple": ["apple", "sandwich-simple"], # Sweet apple filling baked with bread/pastry dough
	"sushi-roll": ["fish-cooked", "coconut-milk"], # Sushi roll with cooked fish and rice-base coconut-milk
	"chocolate-shake": ["cookie-simple", "juice-orange"], # Sweet chocolate cookies shaken with juice
	"sub-sandwich": ["sandwich-simple", "bacon-cooked"], # Loaded bacon sub

	# ===================== EPIC DISHES (Unique + Unique / Unique + Rare) =====================
	"burger-cheese-double": ["burger-simple", "pizza-margherita"], # The ultimate burger-pizza crossover!
	"icecream-sundae": ["chocolate-shake", "donut-simple"], # Ice cream sundae with donut and shake base
	"cake-chocolate": ["pie-apple", "chocolate-shake"], # Delicious dessert chocolate cake
	"sushi-deluxe": ["sushi-roll", "taco-beef"], # Fusion cuisine platter
	"stew-hearty": ["sub-sandwich", "egg-cooked"], # Bread bowl stew with egg

	# ===================== LEGENDARY FEASTS (Epic + Epic) =====================
	"royal-feast-burger": ["burger-cheese-double", "sushi-deluxe"], # Epic burgers and sushi combo
	"mega-turkey-dinner": ["stew-hearty", "sushi-deluxe"], # Heavy epic combo dinner
	"elixir-red": ["icecream-sundae", "cake-chocolate"], # Pure sweet elixir distilled from top desserts
	"ambrosia-cake": ["royal-feast-burger", "mega-turkey-dinner"] # The legendary ultimate food
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
