extends LineEdit
var german_key_board = true
@export var z_to_y = true
@export var ae_to_umlaut = true
@export var right_umlauts = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_text_changed(new_text):
	if german_key_board:
		var saved_caret_column = caret_column
		if text =="":
			return
		if text[saved_caret_column-1].to_lower() == "e" and text.length()>1 and ae_to_umlaut:
			#ÄöÖüÜß"
			if text[saved_caret_column-2] == "a":
				text[saved_caret_column-2] = "ä" 
				text[saved_caret_column-1] = ""
				saved_caret_column -= 1
			elif text[saved_caret_column-2] == "A":
				text[saved_caret_column-2] = "Ä" 
				text[saved_caret_column-1] = ""
				saved_caret_column -= 1
			elif text[saved_caret_column-2] == "o":
				text[saved_caret_column-2] = "ö" 
				text[saved_caret_column-1] = ""
				saved_caret_column -= 1
			elif text[saved_caret_column-2] == "O":
				text[saved_caret_column-2] = "Ö" 
				text[saved_caret_column-1] = ""
				saved_caret_column -= 1
			elif text[saved_caret_column-2] == "u":
				text[saved_caret_column-2] = "ü" 
				text[saved_caret_column-1] = ""
				saved_caret_column -= 1
			elif text[saved_caret_column-2] == "U":
				text[saved_caret_column-2] = "Ü" 
				text[saved_caret_column-1] = ""
				saved_caret_column -= 1
				
		if right_umlauts:
			if text[saved_caret_column-1] == ";":
				text[saved_caret_column-1] = "ö"	
			elif text[saved_caret_column-1] == ":":
				text[saved_caret_column-1] = "Ö"
			elif text[saved_caret_column-1] == "'":
				text[saved_caret_column-1] = "ä"
			elif text[saved_caret_column-1] == '"':
				text[saved_caret_column-1] = "Ä"
			elif text[saved_caret_column-1] == "[":
				text[saved_caret_column-1] = "ü"
			elif text[saved_caret_column-1] == '{':
				text[saved_caret_column-1] = "Ü"
		if text[saved_caret_column-1] == '-':
			text[saved_caret_column-1] = "ß"
			
		if z_to_y:	
			if text[saved_caret_column-1] == "y":
				text[saved_caret_column-1] = "z"
			elif text[saved_caret_column-1] == "z":
				text[saved_caret_column-1] = "y"
		
		caret_column = min(saved_caret_column, text.length())
			
	
