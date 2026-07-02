# Verification Script for new food models
import os

MODELS_DIR = "Models/OBJ format"
PREVIEWS_DIR = "Previews"

foods = {
	"apple": {
		"preview": "res://Previews/apple.png",
		"model": "res://Models/OBJ format/apple.obj"
	},
	"banana": {
		"preview": "res://Previews/banana.png",
		"model": "res://Models/OBJ format/banana.obj"
	},
	"orange": {
		"preview": "res://Previews/orange.png",
		"model": "res://Models/OBJ format/orange.obj"
	},
	"strawberry": {
		"preview": "res://Previews/strawberry.png",
		"model": "res://Models/OBJ format/strawberry.obj"
	},
	"bread": {
		"preview": "res://Previews/bread.png",
		"model": "res://Models/OBJ format/bread.obj"
	},
	"cheese": {
		"preview": "res://Previews/cheese.png",
		"model": "res://Models/OBJ format/cheese.obj"
	},
	"tomato": {
		"preview": "res://Previews/tomato.png",
		"model": "res://Models/OBJ format/tomato.obj"
	},
	"bacon-raw": {
		"preview": "res://Previews/bacon-raw.png",
		"model": "res://Models/OBJ format/bacon-raw.obj"
	},
	"egg": {
		"preview": "res://Previews/egg.png",
		"model": "res://Models/OBJ format/egg.obj"
	},
	"soda-can": {
		"preview": "res://Previews/soda-can.png",
		"model": "res://Models/OBJ format/soda-can.obj"
	},
	"mushroom": {
		"preview": "res://Previews/mushroom.png",
		"model": "res://Models/OBJ format/mushroom.obj"
	},
	"carrot": {
		"preview": "res://Previews/carrot.png",
		"model": "res://Models/OBJ format/carrot.obj"
	},
	"watermelon": {
		"preview": "res://Previews/watermelon.png",
		"model": "res://Models/OBJ format/watermelon.obj"
	},
	"coconut": {
		"preview": "res://Previews/coconut.png",
		"model": "res://Models/OBJ format/coconut.obj"
	},
	"hot-dog-raw": {
		"preview": "res://Previews/hot-dog-raw.png",
		"model": "res://Models/OBJ format/hot-dog-raw.obj"
	},
	"meat-raw": {
		"preview": "res://Previews/meat-raw.png",
		"model": "res://Models/OBJ format/meat-raw.obj"
	},
	"cabbage": {
		"preview": "res://Previews/cabbage.png",
		"model": "res://Models/OBJ format/cabbage.obj"
	},
	"avocado": {
		"preview": "res://Previews/avocado.png",
		"model": "res://Models/OBJ format/avocado.obj"
	},
	"onion": {
		"preview": "res://Previews/onion.png",
		"model": "res://Models/OBJ format/onion.obj"
	},
	"fish": {
		"preview": "res://Previews/fish.png",
		"model": "res://Models/OBJ format/fish.obj"
	},
	"chocolate": {
		"preview": "res://Previews/chocolate.png",
		"model": "res://Models/OBJ format/chocolate.obj"
	},
	"milk-carton": {
		"preview": "res://Previews/carton.png",
		"model": "res://Models/OBJ format/carton.obj"
	},
	"bacon-cooked": {
		"preview": "res://Previews/bacon.png",
		"model": "res://Models/OBJ format/bacon.obj"
	},
	"egg-cooked": {
		"preview": "res://Previews/egg-cooked.png",
		"model": "res://Models/OBJ format/egg-cooked.obj"
	},
	"meat-patty": {
		"preview": "res://Previews/meat-patty.png",
		"model": "res://Models/OBJ format/meat-patty.obj"
	},
	"ketchup": {
		"preview": "res://Previews/bottle-ketchup.png",
		"model": "res://Models/OBJ format/bottle-ketchup.obj"
	},
	"mustard": {
		"preview": "res://Previews/bottle-musterd.png",
		"model": "res://Models/OBJ format/bottle-musterd.obj"
	},
	"hot-dog-cooked": {
		"preview": "res://Previews/hot-dog.png",
		"model": "res://Models/OBJ format/hot-dog.obj"
	},
	"french-fries": {
		"preview": "res://Previews/fries.png",
		"model": "res://Models/OBJ format/fries.obj"
	},
	"salad-fresh": {
		"preview": "res://Previews/salad.png",
		"model": "res://Models/OBJ format/salad.obj"
	},
	"sandwich-simple": {
		"preview": "res://Previews/sandwich.png",
		"model": "res://Models/OBJ format/sandwich.obj"
	},
	"donut-simple": {
		"preview": "res://Previews/donut.png",
		"model": "res://Models/OBJ format/donut.obj"
	},
	"cookie-simple": {
		"preview": "res://Previews/cookie.png",
		"model": "res://Models/OBJ format/cookie.obj"
	},
	"cup-coffee": {
		"preview": "res://Previews/cup-coffee.png",
		"model": "res://Models/OBJ format/cup-coffee.obj"
	},
	"juice-orange": {
		"preview": "res://Previews/soda.png",
		"model": "res://Models/OBJ format/soda.obj"
	},
	"coconut-milk": {
		"preview": "res://Previews/coconut-half.png",
		"model": "res://Models/OBJ format/coconut-half.obj"
	},
	"fish-cooked": {
		"preview": "res://Previews/meat-cooked.png",
		"model": "res://Models/OBJ format/meat-cooked.obj"
	},
	"burger-simple": {
		"preview": "res://Previews/burger.png",
		"model": "res://Models/OBJ format/burger.obj"
	},
	"hot-dog-complete": {
		"preview": "res://Previews/corn-dog.png",
		"model": "res://Models/OBJ format/corn-dog.obj"
	},
	"taco-beef": {
		"preview": "res://Previews/taco.png",
		"model": "res://Models/OBJ format/taco.obj"
	},
	"pizza-margherita": {
		"preview": "res://Previews/pizza.png",
		"model": "res://Models/OBJ format/pizza.obj"
	},
	"pie-apple": {
		"preview": "res://Previews/pie.png",
		"model": "res://Models/OBJ format/pie.obj"
	},
	"sushi-roll": {
		"preview": "res://Previews/rice-ball.png",
		"model": "res://Models/OBJ format/rice-ball.obj"
	},
	"chocolate-shake": {
		"preview": "res://Previews/frappe.png",
		"model": "res://Models/OBJ format/frappe.obj"
	},
	"sub-sandwich": {
		"preview": "res://Previews/sub.png",
		"model": "res://Models/OBJ format/sub.obj"
	},
	"burger-cheese-double": {
		"preview": "res://Previews/burger-cheese.png",
		"model": "res://Models/OBJ format/burger-cheese.obj"
	},
	"icecream-sundae": {
		"preview": "res://Previews/sundae.png",
		"model": "res://Models/OBJ format/sundae.obj"
	},
	"cake-chocolate": {
		"preview": "res://Previews/cake.png",
		"model": "res://Models/OBJ format/cake.obj"
	},
	"sushi-deluxe": {
		"preview": "res://Previews/sushi-salmon.png",
		"model": "res://Models/OBJ format/sushi-salmon.obj"
	},
	"stew-hearty": {
		"preview": "res://Previews/bowl-soup.png",
		"model": "res://Models/OBJ format/bowl-soup.obj"
	},
	"royal-feast-burger": {
		"preview": "res://Previews/burger-cheese-double.png",
		"model": "res://Models/OBJ format/burger-cheese-double.obj"
	},
	"mega-turkey-dinner": {
		"preview": "res://Previews/turkey.png",
		"model": "res://Models/OBJ format/turkey.obj"
	},
	"elixir-red": {
		"preview": "res://Previews/wine-red.png",
		"model": "res://Models/OBJ format/wine-red.obj"
	},
	"ambrosia-cake": {
		"preview": "res://Previews/cake-birthday.png",
		"model": "res://Models/OBJ format/cake-birthday.obj"
	}
}

missing_count = 0
for name, paths in foods.items():
	model_path = paths["model"].replace("res://", "")
	preview_path = paths["preview"].replace("res://", "")
	
	if not os.path.exists(model_path):
		print(f"Missing model for {name}: {model_path}")
		missing_count += 1
		
	if not os.path.exists(preview_path):
		print(f"Missing preview for {name}: {preview_path}")
		missing_count += 1

if missing_count == 0:
	print("All models and previews verified!")
else:
	print(f"Total missing: {missing_count}")
