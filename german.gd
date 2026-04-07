extends Control
var new_words : Array
var prev_left_size = 0
signal closed
signal test_words


# Called when the node enters the scene tree for the first time.
func _ready():
	new_words = []
	glue_button_manage()
	


	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_forward_pressed():
	var text_left = %TextLeft.text.split("\n")
	var text_right = %TextRight.text.split("\n")
	var slownik = []
	if text_left.size() != text_right.size():
		%ErrorLabel.text = "The number of lines on the left and right is not even!"
		return
	for i in range(text_left.size()):
		if text_left[i].strip_edges() == "" and text_right[i].strip_edges() == "":
			continue
		if text_left[i].strip_edges() == "" or text_right[i].strip_edges() == "":	
			%ErrorLabel.text = "Each word/sentence needs translation!"
			return
		slownik.append([text_left[i].strip_edges(), text_right[i].strip_edges()])
	slownik.sort_custom(case_insensitive_sort)
	%ErrorLabel.text = ""
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
	%Back.visible = true
	%Finish.visible = true
	%Menu.visible = false
	


func _on_text_left_text_changed():
	glue_button_manage()
	if %TextLeft.text.length() - prev_left_size > 1 or (%TextLeft.text.length() - prev_left_size == 1 and %TextLeft.text[-1] == "\n"):
		check_for_dashes()
	delete_empty_lines(%TextLeft)
	var number_of_lines = %TextLeft.text.split("\n").size()
	%LinesCounterLeft.text = str(number_of_lines) + " lines" if number_of_lines > 0 else ""
	if %LinesCounterLeft.text != %LinesCounterRight.text and %LinesCounterLeft.text != "" and %LinesCounterRight.text != "" :
		%LinesCounterLeft.label_settings.font_color = Color.RED
		%LinesCounterRight.label_settings.font_color = Color.RED
	else:
		%LinesCounterLeft.label_settings.font_color = Color.WHITE
		%LinesCounterRight.label_settings.font_color = Color.WHITE
	prev_left_size = %TextLeft.text.length()

func check_for_dashes():
	var cline = %TextLeft.get_caret_line()
	var column = %TextLeft.get_caret_column()
	
	var result_left = ""
	var result_right = %TextRight.text
	for line in %TextLeft.text.split("\n"):
		if line.count(" - ") == 1:
			result_left += line.get_slice("-",0).strip_edges() + "\n"
			result_right += line.get_slice("-",1).strip_edges() + "\n"
		elif line.count(" – ") == 1:
			result_left += line.get_slice("–",0).strip_edges() + "\n"
			result_right += line.get_slice("–",1).strip_edges() + "\n"
		elif line.count(" — ") == 1:
			result_left += line.get_slice("—",0).strip_edges() + "\n"
			result_right += line.get_slice("—",1).strip_edges() + "\n"
		
		else:
			result_left += line + "\n"
#	result_left = result_left.rstrip("\n")
#	result_right = result_right.rstrip("\n")
	
	%TextLeft.text = result_left
	if result_right!= "":
		%TextRight.text = result_right
		_on_text_right_text_changed()
		
	cline = min(cline, %TextLeft.get_line_count() - 1)
	column = min(column, %TextLeft.get_line(cline).length())

	%TextLeft.set_caret_line(cline)
	%TextLeft.set_caret_column(column)

func delete_empty_lines(text_node : TextEdit):
	var line = text_node.get_caret_line()
	var column = text_node.get_caret_column()
	
	while(text_node.text.contains("\n\n")):
		text_node.text = text_node.text.replace("\n\n","\n")
	
	line = min(line, text_node.get_line_count() - 1)
	column = min(column, text_node.get_line(line).length())

	text_node.set_caret_line(line)
	text_node.set_caret_column(column)


func _on_text_right_text_changed():
	glue_button_manage()
	delete_empty_lines(%TextRight)
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
		#var date_old = Time.get_datetime_dict_from_system()
		#date_old["month"] -= 1
		#var str_date_old = Time.get_datetime_string_from_datetime_dict(date_old, false)
		#print(str_date_old)
		var new_record = {"original":german, "translation":english, "is_sentence":sentence, "weight": how_much_do_i_know, "date_added": Time.get_datetime_string_from_system()}
		#print("ADD?")
		NewUtility.BIG_ARRAY.append(new_record)
		new_words.append(new_record)
		record.queue_free()
	NewUtility.BIG_ARRAY.sort_custom(case_insensitive_sort_set)
	#print("BIG_ARRAY"," ", NewUtility.BIG_ARRAY)
	%ScrollModifyContainer.visible = false 
	%WhatNext.visible = true
	%Finish.visible = false
	%TextLeft.text = ""
	%TextRight.text = ""
	%LinesCounterLeft.text = ""
	%LinesCounterRight.text = ""
	NewUtility.save_array()
	#NewUtility.update_safe_array()

	
func go_back_to_input():
	%InputContainer.visible = true 
	%Forward.visible = true
	%WhatNext.visible = false
	%Menu.visible = true
	%Back.visible = false
	
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
	for record in NewUtility.BIG_ARRAY:
		if record["original"].to_lower() == word.to_lower():
			return true
	return false


func _on_yes_pressed():
	NewUtility.SMALL_ARRAY = new_words	
	new_words = []
	test_words.emit()
	go_back_to_input()


func _on_no_add_more_pressed():
	go_back_to_input()


func _on_no_back_pressed():
	go_back_to_input()
	new_words = []
	closed.emit()


func _on_menu_pressed() -> void:
	go_back_to_input()
	%TextLeft.text = ""
	%TextRight.text = ""
	%LinesCounterLeft.text = ""
	%LinesCounterRight.text = ""
	%LinesCounterLeft.label_settings.font_color = Color.WHITE
	%LinesCounterRight.label_settings.font_color = Color.WHITE
	closed.emit()
	new_words = []


func _on_back_pressed() -> void:
	for child in %ModifyContainer.get_children():
		if child != %NewWord:
			child.queue_free()
	%InputContainer.visible = true 
	%ScrollModifyContainer.visible = false
	%Forward.visible = true
	%WhatNext.visible = false
	%Finish.visible = false
	%Menu.visible = true
	%Back.visible = false

func glue_button_manage():
	%Forward.disabled = %TextLeft.text.strip_edges().length() == 0 or %TextRight.text.strip_edges().length() == 0
		
