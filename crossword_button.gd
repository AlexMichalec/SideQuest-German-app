extends Control
@export_enum("white", "black", "gray") var square_type : String
@export var to_right = self
@export var to_down = self
@export var next_one = self
@export var previous = self
var correct_letter =""
var horizontal_info = ""
var vertical_info = ""
var horizontal_number = 0
var vertical_number = 0
var direction = 0
var do_hasla = false
var force_down = false
var force_right = false
var prev_filled = ""
@export var connected_to = self
# Called when the node enters the scene tree for the first time.
func _ready():
	if square_type == "white":
		%Label.visible = false
		%Input.visible = true
		%ColorRect.color = Color.WHITE
	elif square_type == "black":
		%Label.visible = false
		%Input.visible = false
		%ColorRect.visible = false
		%ColorRect.color = Color.BLACK
	elif square_type == "gray":
		%Label.visible = true
		%Input.visible = false
		%ColorRect.color = Color.WEB_GRAY
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): 
	if %Input.has_focus() and Input.is_action_just_pressed("BACK"):
		#%Input
		force_down = false
		force_right = false
		previous.get_node("Input").grab_focus()
	if %Input.has_focus() and Input.is_action_just_pressed("DOWN"):
		force_down = true
		force_right = false
	if %Input.has_focus() and Input.is_action_just_pressed("RIGHT"):
		force_down = false
		force_right = true
	pass


func _on_input_text_changed(new_text):
	if new_text in "0123456789".split():
		%Input.text = ""
		return
	if square_type != "white":
		return
	if new_text.length() >= 1:
		%Input.text = %Input.text[-1].capitalize()
		%Input.caret_column = 1
	
	if do_hasla:
		connected_to.get_node("Input").text = %Input.text
	
	if force_down:
		to_down.get_node("Input").grab_focus()
		to_down.direction = -1
		if to_down!=self:
			to_down.previous = self
	elif force_right:
		to_right.get_node("Input").grab_focus()
		to_right.direction = 1
		if to_right!=self:
			to_right.previous = self
	elif direction != 0:
		if direction == 1:
			to_right.get_node("Input").grab_focus()
			to_right.direction = 1
			if to_right!=self:
				to_right.previous = self
		else:
			to_down.get_node("Input").grab_focus()
			to_down.direction = -1
			if to_down!=self:
				to_down.previous = self
		direction = 0
	elif to_right == self and to_down!= self:
		to_down.get_node("Input").grab_focus()
		to_down.direction = -1
		if to_down!=self:
			to_down.previous = self
	elif to_down == self and to_right != self:
		to_right.get_node("Input").grab_focus()
		to_right.direction = 1
		if to_right!=self:
			to_right.previous = self
	elif horizontal_number != 0:
		to_right.get_node("Input").grab_focus()
		to_right.direction = 1
		if to_right!=self:
			to_right.previous = self
	elif vertical_number != 0:
		to_down.get_node("Input").grab_focus()
		to_down.direction = -1
		if to_down!=self:
			to_down.previous = self
	elif to_right.get_node("Input").text != "" and to_right.get_node("Input").text != " " and to_down.get_node("Input").text in [""," "]:
		to_down.get_node("Input").grab_focus()
		to_down.direction = -1
		if to_down!=self:
			to_down.previous = self
	elif to_down.get_node("Input").text != "" and to_down.get_node("Input").text != " " and to_right.get_node("Input").text in [""," "]:
		to_right.get_node("Input").grab_focus()
		to_right.direction = -1
		if to_right!=self:
			to_right.previous = self
	else:
		to_right.get_node("Input").grab_focus()
		to_right.direction = 1
		if to_right!=self:
			to_right.previous = self
	if %Input.has_focus():
		%Input.release_focus()
	
func set_text(text:String):
	%HorizontalScoreNumber.visible = false
	%VerticalScoreNumber.visible = false
	previous = self
	%SolutionNumber.visible = false
	do_hasla = false
	to_right = self
	to_down = self
	direction = 0
	horizontal_number = 0
	vertical_number = 0
	%HorizontalNumber.visible = false
	%VerticalNumber.visible = false
	square_type = "white"
	%Label.visible = false
	%Input.visible = true
	%ColorRect.color = Color.WHITE
	%ColorRect.visible = true
	%Input.text = "" #text
	correct_letter = text
	
func set_info(text:String, number:int, horizontal:bool):
	%ColorRect.color = Color.GRAY
	if horizontal:
		horizontal_info = text
		horizontal_number = number
		%HorizontalNumber.visible = true
		%HorizontalNumber.text = str(number)
	else:
		vertical_info = text
		vertical_number = number
		%VerticalNumber.visible = true
		%VerticalNumber.text = str(number)
	

func set_empty():
	%HorizontalScoreNumber.visible = false
	%VerticalScoreNumber.visible = false
	previous = self
	%SolutionNumber.visible = false
	do_hasla = false
	%HorizontalNumber.visible = false
	%VerticalNumber.visible = false
	square_type = "black"
	%Label.visible = false
	%Input.visible = false
	%ColorRect.visible = false
	%ColorRect.color = Color.BLACK
	
func check():
	if square_type!= "white":
		return
	if %Input.text == "":
		%ColorRect.color = Color.AQUA
		%Input.text = correct_letter
	elif %Input.text == correct_letter:
		%ColorRect.color = Color.SPRING_GREEN
	else:
		%ColorRect.color = Color.INDIAN_RED
		#%Input.text = correct_letter
	
	


func _on_input_focus_entered():
	force_down = false
	force_right = false
	if %ColorRect.color == Color.WHITE or %ColorRect.color == Color.GRAY or %ColorRect.color == Color.GOLDENROD:
		%Input.text = ""
		if do_hasla:
			connected_to.get_node("Input").text = ""
	elif %ColorRect.color == Color.INDIAN_RED:
		%ColorRect.color = Color.AQUA
		%Input.text = correct_letter
		%Input.release_focus()
	else:
		%Input.release_focus()
		

func set_important(haslo_button, number:int):
	%ColorRect.color = Color.GOLDENROD
	do_hasla = true
	connected_to = haslo_button
	%SolutionNumber.visible = true
	%SolutionNumber.text = str(number)
	
func show_score_horizontal(points:int):
	%HorizontalScoreNumber.text = "+" + str(points) + "p"
	%HorizontalScoreNumber.visible = true
	
func show_score_vertical(points:int):
	%VerticalScoreNumber.text = "+" + str(points) + "p"
	%VerticalScoreNumber.visible = true
	
	
