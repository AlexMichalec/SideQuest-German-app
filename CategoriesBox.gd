extends MarginContainer
var Categories = {}
var SampleColors = [Color.RED, Color.ORANGE_RED, Color.ORANGE, Color.YELLOW, Color.GREEN, Color.SEA_GREEN, Color.BLUE, Color.AQUA, Color.VIOLET, Color.PURPLE, Color.HOT_PINK]
var counter = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_new_category_button_pressed():
	var new_button = %SampleCat.duplicate()
	new_button.text = "Category "+ str(counter)
	new_button.visible = true
	%CategoriesContainer.add_child(new_button)
	%CategoriesContainer.move_child(%NewCategoryButton, -1)
	var chosen_color = SampleColors.pick_random()
	Categories["CAT"+str(counter)] = {"name": "", "sub_categories":[], "color": chosen_color, "standard_time" : 60, "standard_exp" : 20}
	new_button.add_theme_stylebox_override("normal", new_button.get_theme_stylebox("normal").duplicate())
	new_button.add_theme_stylebox_override("hover", new_button.get_theme_stylebox("hover").duplicate())
	new_button.get_theme_stylebox("normal").bg_color = chosen_color
	new_button.get_theme_stylebox("hover").bg_color = chosen_color
	
	var brightness = 0.299 * chosen_color.r + 0.587 * chosen_color.g + 0.114 * chosen_color.b
	var text_color: Color

	if brightness > 0.5:
		text_color = Color.BLACK
	else:
		text_color = Color.WHITE

	new_button.add_theme_color_override("font_color", text_color)
	new_button.add_theme_color_override("font_hover_color", text_color)
	#new_button.get_theme_override_colors("hover").font_color = chosen_color
	
	counter += 1
