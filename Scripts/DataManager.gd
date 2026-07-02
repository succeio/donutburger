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
		"name": "Common",
		"color": Color(0.8, 0.8, 0.8),
		"value": 10
	},
	Rarity.RARE: {
		"name": "Rare",
		"color": Color(0.1, 0.8, 0.1),
		"value": 50
	},
	Rarity.UNIQUE: {
		"name": "Unique",
		"color": Color(0.1, 0.5, 0.9),
		"value": 250
	},
	Rarity.EPIC: {
		"name": "Epic",
		"color": Color(0.6, 0.1, 0.9),
		"value": 1200
	},
	Rarity.LEGENDARY: {
		"name": "Legendary",
		"color": Color(0.9, 0.6, 0.0),
		"value": 6000
	}
}

var foods = {
	# COMMON
	"apple": {
		"name": "Apple",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/apple.png",
		"model": "res://Models/OBJ format/apple.obj"
	},
	"banana": {
		"name": "Banana",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/banana.png",
		"model": "res://Models/OBJ format/banana.obj"
	},
	"orange": {
		"name": "Orange",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/orange.png",
		"model": "res://Models/OBJ format/orange.obj"
	},
	"strawberry": {
		"name": "Strawberry",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/strawberry.png",
		"model": "res://Models/OBJ format/strawberry.obj"
	},
	"bread": {
		"name": "Bread",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/bread.png",
		"model": "res://Models/OBJ format/bread.obj"
	},
	"cheese": {
		"name": "Cheese",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/cheese.png",
		"model": "res://Models/OBJ format/cheese.obj"
	},
	"tomato": {
		"name": "Tomato",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/tomato.png",
		"model": "res://Models/OBJ format/tomato.obj"
	},
	"bacon": {
		"name": "Bacon",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/bacon.png",
		"model": "res://Models/OBJ format/bacon.obj"
	},
	"egg": {
		"name": "Egg",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/egg.png",
		"model": "res://Models/OBJ format/egg.obj"
	},
	"soda-can": {
		"name": "Soda Can",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/soda-can.png",
		"model": "res://Models/OBJ format/soda-can.obj"
	},
	"mushroom": {
		"name": "Mushroom",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/mushroom.png",
		"model": "res://Models/OBJ format/mushroom.obj"
	},
	"carrot": {
		"name": "Carrot",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/carrot.png",
		"model": "res://Models/OBJ format/carrot.obj"
	},
	"watermelon": {
		"name": "Watermelon",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/watermelon.png",
		"model": "res://Models/OBJ format/watermelon.obj"
	},
	"coconut": {
		"name": "Coconut",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/coconut.png",
		"model": "res://Models/OBJ format/coconut.obj"
	},
	"hot-dog-raw": {
		"name": "Raw Sausage",
		"rarity": Rarity.COMMON,
		"preview": "res://Previews/hot-dog-raw.png",
		"model": "res://Models/OBJ format/hot-dog-raw.obj"
	},

	# RARE
	"salad": {
		"name": "Fruit Salad",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/salad.png",
		"model": "res://Models/OBJ format/salad.obj"
	},
	"sandwich": {
		"name": "Cheese Sandwich",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/sandwich.png",
		"model": "res://Models/OBJ format/sandwich.obj"
	},
	"egg-cooked": {
		"name": "Fried Egg & Bacon",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/egg-cooked.png",
		"model": "res://Models/OBJ format/egg-cooked.obj"
	},
	"fries": {
		"name": "French Fries",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/fries.png",
		"model": "res://Models/OBJ format/fries.obj"
	},
	"donut": {
		"name": "Glazed Donut",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/donut.png",
		"model": "res://Models/OBJ format/donut.obj"
	},
	"cookie": {
		"name": "Cookie",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/cookie.png",
		"model": "res://Models/OBJ format/cookie.obj"
	},
	"cup-coffee": {
		"name": "Coffee Cup",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/cup-coffee.png",
		"model": "res://Models/OBJ format/cup-coffee.obj"
	},
	"taco": {
		"name": "Taco",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/taco.png",
		"model": "res://Models/OBJ format/taco.obj"
	},
	"hot-dog": {
		"name": "Hot Dog",
		"rarity": Rarity.RARE,
		"preview": "res://Previews/hot-dog.png",
		"model": "res://Models/OBJ format/hot-dog.obj"
	},

	# UNIQUE
	"burger": {
		"name": "Classic Burger",
		"rarity": Rarity.UNIQUE,
		"preview": "res://Previews/burger.png",
		"model": "res://Models/OBJ format/burger.obj"
	},
	"donut-sprinkles": {
		"name": "Sprinkled Donut",
		"rarity": Rarity.UNIQUE,
		"preview": "res://Previews/donut-sprinkles.png",
		"model": "res://Models/OBJ format/donut-sprinkles.obj"
	},
	"sundae": {
		"name": "Ice Cream Sundae",
		"rarity": Rarity.UNIQUE,
		"preview": "res://Previews/sundae.png",
		"model": "res://Models/OBJ format/sundae.obj"
	},
	"pizza": {
		"name": "Pepperoni Pizza",
		"rarity": Rarity.UNIQUE,
		"preview": "res://Previews/pizza.png",
		"model": "res://Models/OBJ format/pizza.obj"
	},
	"muffin": {
		"name": "Muffin",
		"rarity": Rarity.UNIQUE,
		"preview": "res://Previews/muffin.png",
		"model": "res://Models/OBJ format/muffin.obj"
	},
	"waffle": {
		"name": "Sweet Waffle",
		"rarity": Rarity.UNIQUE,
		"preview": "res://Previews/waffle.png",
		"model": "res://Models/OBJ format/waffle.obj"
	},

	# EPIC
	"burger-cheese-double": {
		"name": "Double Cheese Burger",
		"rarity": Rarity.EPIC,
		"preview": "res://Previews/burger-cheese-double.png",
		"model": "res://Models/OBJ format/burger-cheese-double.obj"
	},
	"cake": {
		"name": "Strawberry Cake",
		"rarity": Rarity.EPIC,
		"preview": "res://Previews/cake.png",
		"model": "res://Models/OBJ format/cake.obj"
	},
	"pie": {
		"name": "Homemade Pie",
		"rarity": Rarity.EPIC,
		"preview": "res://Previews/pie.png",
		"model": "res://Models/OBJ format/pie.obj"
	},

	# LEGENDARY
	"cake-birthday": {
		"name": "Grand Birthday Feast",
		"rarity": Rarity.LEGENDARY,
		"preview": "res://Previews/cake-birthday.png",
		"model": "res://Models/OBJ format/cake-birthday.obj"
	}
}

# Auto-generation helper for 3x upgrade combinations
# If we have 3 identical products, upgrading them returns a recipe.
# Handled dynamically in game code. But we still define the cross-product combinations.
var recipes = [
	# COMMON -> RARE (2 ingredients)
	{
		"inputs": ["apple", "banana"],
		"output": "salad"
	},
	{
		"inputs": ["bread", "cheese"],
		"output": "sandwich"
	},
	{
		"inputs": ["tomato", "egg"],
		"output": "egg-cooked"
	},
	{
		"inputs": ["orange", "soda-can"],
		"output": "fries"
	},
	{
		"inputs": ["orange", "strawberry"],
		"output": "donut"
	},
	{
		"inputs": ["bread", "strawberry"],
		"output": "cookie"
	},
	{
		"inputs": ["mushroom", "coconut"],
		"output": "cup-coffee"
	},
	{
		"inputs": ["tomato", "carrot"],
		"output": "taco"
	},
	{
		"inputs": ["bread", "hot-dog-raw"],
		"output": "hot-dog"
	},

	# RARE -> UNIQUE (2 ingredients)
	{
		"inputs": ["sandwich", "fries"],
		"output": "burger"
	},
	{
		"inputs": ["donut", "strawberry"],
		"output": "donut-sprinkles"
	},
	{
		"inputs": ["egg-cooked", "banana"],
		"output": "sundae"
	},
	{
		"inputs": ["sandwich", "tomato"],
		"output": "pizza"
	},
	{
		"inputs": ["cookie", "cup-coffee"],
		"output": "muffin"
	},
	{
		"inputs": ["donut", "cookie"],
		"output": "waffle"
	},

	# UNIQUE -> EPIC (2 ingredients)
	{
		"inputs": ["burger", "cheese"],
		"output": "burger-cheese-double"
	},
	{
		"inputs": ["donut-sprinkles", "sundae"],
		"output": "cake"
	},
	{
		"inputs": ["waffle", "muffin"],
		"output": "pie"
	},

	# EPIC -> LEGENDARY (2 ingredients)
	{
		"inputs": ["burger-cheese-double", "cake"],
		"output": "cake-birthday"
	},
	{
		"inputs": ["pie", "cake"],
		"output": "cake-birthday"
	}
]

# Upgrades a single food ID to a random food of next tier (used for 3 identical items upgrade)
func get_next_tier_food(food_id: String) -> String:
	if not foods.has(food_id):
		return ""
	var current_rarity = foods[food_id]["rarity"]
	if current_rarity == Rarity.LEGENDARY:
		return ""
		
	var next_rarity = current_rarity + 1
	var possibilities = []
	for id in foods:
		if foods[id]["rarity"] == next_rarity:
			possibilities.append(id)
			
	if possibilities.size() > 0:
		return possibilities[randi() % possibilities.size()]
	return ""

# Finds if there is a recipe matching the given two inputs.
# Returns output food ID or empty string.
func find_recipe(input1: String, input2: String) -> String:
	var sorted_inputs = [input1, input2]
	sorted_inputs.sort()
	
	for recipe in recipes:
		var recipe_inputs = recipe["inputs"].duplicate()
		recipe_inputs.sort()
		if sorted_inputs == recipe_inputs:
			return recipe["output"]
			
	return ""
