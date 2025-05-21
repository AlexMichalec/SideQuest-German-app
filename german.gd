extends Control
var BIG_SET :Array
var new_words : Array
signal closed
signal test_words


# Called when the node enters the scene tree for the first time.
func _ready():
	new_words = []
	if get_tree().current_scene == self:
		BIG_SET = load_array()


	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_forward_pressed():
	var text_left = %TextLeft.text.split("\n")
	var text_right = %TextRight.text.split("\n")
	var slownik = []
	if text_left.size() != text_right.size():
		print("SPRAWDŹ CZY LICZBA LINII SIĘ ZGADZA!")
		return
	for i in range(text_left.size()):
		slownik.append([text_left[i].strip_edges(), text_right[i].strip_edges()])
	slownik.sort_custom(case_insensitive_sort)
	var previous = ["dsoifjsjf"]
	for s in slownik:
		var new_word = %NewWord.duplicate()
		%ModifyContainer.add_child(new_word)
		new_word.visible = true
		new_word.get_node("HBoxContainer/German").text = s[0]
		new_word.get_node("HBoxContainer/English").text = s[1]
		if s[0].strip_edges().split(" ").size() >= 3:
			new_word.get_node("HBoxContainer/Sentence").button_pressed = true
		if already_in_set(s[0]):
			new_word.get_node("HBoxContainer/Skip").button_pressed = true
			new_word.get_node("HBoxContainer/Skip").disabled = true
			new_word.get_node("HBoxContainer/Skip").tooltip_text = "It's already in the set!"
		if previous[0].to_lower() == s[0].to_lower():
			new_word.get_node("HBoxContainer/Skip").button_pressed = true
			new_word.get_node("HBoxContainer/Skip").disabled = true
			new_word.get_node("HBoxContainer/Skip").tooltip_text = "Appeared more than once in the Input!"
		previous = s
	%InputContainer.visible = false
	%ScrollModifyContainer.visible = true
	%Forward.visible = false
	%Finish.visible = true
	


func _on_text_left_text_changed():
	var number_of_lines = %TextLeft.text.split("\n").size()
	%LinesCounterLeft.text = str(number_of_lines) + " lines" if number_of_lines > 0 else ""
	if %LinesCounterLeft.text != %LinesCounterRight.text and %LinesCounterLeft.text != "" and %LinesCounterRight.text != "" :
		%LinesCounterLeft.label_settings.font_color = Color.RED
		%LinesCounterRight.label_settings.font_color = Color.RED
	else:
		%LinesCounterLeft.label_settings.font_color = Color.WHITE
		%LinesCounterRight.label_settings.font_color = Color.WHITE

func _on_text_right_text_changed():
	var number_of_lines = %TextRight.text.split("\n").size()
	%LinesCounterRight.text = str(number_of_lines) + " lines" if number_of_lines > 0 else ""
	if %LinesCounterLeft.text != %LinesCounterRight.text and %LinesCounterLeft.text != "" and %LinesCounterRight.text != "" :
		%LinesCounterLeft.label_settings.font_color = Color.RED
		%LinesCounterRight.label_settings.font_color = Color.RED
	else:
		%LinesCounterLeft.label_settings.font_color = Color.WHITE
		%LinesCounterRight.label_settings.font_color = Color.WHITE


func _on_finish_pressed():
	for record in %ModifyContainer.get_children():
		if record.get_node("HBoxContainer/German").text == "":
			continue
		if record.get_node("HBoxContainer/Skip").button_pressed:
			record.queue_free()
			continue
		var german = record.get_node("HBoxContainer/German").text
		var english = record.get_node("HBoxContainer/English").text
		var sentence = record.get_node("HBoxContainer/Sentence").button_pressed
		var important = record.get_node("HBoxContainer/Important").button_pressed
		var how_much_do_i_know = 0
		var gender = ""
		if sentence:
			if not german[-1] in ".?!,":
				german = german + "."
			if german[-1] == ",":
				german[-1] = "."
			german[0] = german[0].to_upper()
		else:
			german = german.rstrip(",.")
			if german.split(" ")[0].to_upper() in ["DER", "DIE", "DAS"]:
				german[0] = german[0].to_lower()
			"""
			if german.split(" ")[0].to_upper() == "DIE":
				gender = "female"
			if german.split(" ")[0].to_upper() == "DAS":
				gender = "neutral"
			if german.split(" ")[0].to_upper() == "DER":
				gender = "male"
			"""
		
		var new_record = {"original":german, "translation":english, "is_sentence":sentence, "weight": how_much_do_i_know, "date_added": Time.get_datetime_string_from_system()}
		
		BIG_SET.append(new_record)
		new_words.append(new_record)
		record.queue_free()
	BIG_SET.sort_custom(case_insensitive_sort_set)
	
	%ScrollModifyContainer.visible = false 
	%WhatNext.visible = true
	%Finish.visible = false
	%TextLeft.text = ""
	%TextRight.text = ""
	%LinesCounterLeft.text = ""
	%LinesCounterRight.text = ""
	save_array()
	#print(BIG_SET)
	#for n in new_words:
	#	print(n)
	
func go_back_to_input():
	%InputContainer.visible = true 
	%Forward.visible = true
	%WhatNext.visible = false
	
func case_insensitive_sort(a, b):
	return a[0].to_lower() < b[0].to_lower()
	
func case_insensitive_sort_set(a, b):
	var a_word : String = a["original"]
	if not a["is_sentence"] and a_word.split(" ")[0].to_upper() in ["DIE", "DAS", "DER"]:
		a_word = a_word.right(-4)
	var b_word = b["original"]
	if not b["is_sentence"] and b_word.split(" ")[0].to_upper() in ["DIE", "DAS", "DER"]:
		b_word = b_word.right(-4)
	return a_word.to_lower() < b_word.to_lower()
	
func sortowanie_po_poznaniu(a,b):
	return a[4] > b[4]
	
func already_in_set(word):
	for record in BIG_SET:
		if record["original"].to_lower() == word.to_lower():
			return true
	return false

func save_array():
	var file = FileAccess.open("user://FiszkiGerman.json", FileAccess.WRITE)
	var json_string = JSON.stringify(BIG_SET)  # Convert array to JSON
	file.store_string(json_string)  # Save to file
	file.close()
	
func load_array():
	if not FileAccess.file_exists("user://FiszkiGerman.json"):
		print("File not found!")
		return []
	
	var file = FileAccess.open("user://FiszkiGerman.json", FileAccess.READ)
	var json_string = file.get_as_text()  # Read the file content
	file.close()
	
	var json = JSON.parse_string(json_string)  # Convert JSON back to array
	return json if json is Array else []


func _on_yes_pressed():
	test_words.emit()


func _on_no_add_more_pressed():
	go_back_to_input()


func _on_no_back_pressed():
	go_back_to_input()
	new_words = []
	closed.emit()
