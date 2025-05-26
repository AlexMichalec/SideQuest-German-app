extends VBoxContainer
var correct_answer = ""
var correct_sentence = ""
var question_type = 0
var given_tip = ""
var tip_array = []
var BIG_SET: Array
var is_sentence = false
var score = 0
var points = 0
var question_types = [1,2,3]
var question_set_changed = false
signal closed

# Called when the node enters the scene tree for the first time.
func _ready():
	BIG_SET = load_array()
	new_question()
	pass # Replace with function body.
	%CopyButton.button_pressed = true
	%TranslateButton.button_pressed = true
	%FillButton.button_pressed = true 
	%z_to_y.button_pressed = %Answer.z_to_y
	%ae_to_a.button_pressed = %Answer.ae_to_umlaut 
	%right_umlaufts.button_pressed = %Answer.right_umlauts

func start():
	score = 0
	new_question()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func new_question():
	if BIG_SET.size()==0:
		return
	%Score.text = str(score) + " points"
	points = 10
	%Answer.text = ""
	var q_type = question_types.pick_random()
	question_type = q_type
	var new_q = BIG_SET.pick_random()
	if q_type == 1:
		if new_q["is_sentence"]:
			%Tip.text = "Copy the sentence!"
			points = 6
		else:
			%Tip.text = "Copy the word!"
			points = 4
		%Question.text = new_q["original"]
		%Question.editable = true
		%Tip.editable = false
		correct_answer = new_q["original"]
		given_tip = new_q["translation"]
		is_sentence = new_q["is_sentence"]
	elif q_type == 2:
		while new_q["is_sentence"]:
			new_q = BIG_SET.pick_random()
		%Tip.text = "Write it in German!"
		%Question.text = new_q["translation"]
		correct_answer = new_q["original"]
		%Question.editable = true
		%Tip.editable = false
		given_tip = ""
		tip_array = []
		for c in correct_answer:
			if c == " ":
				tip_array.append(" ")
			else:
				tip_array.append(" _")
		tip_array[0] = "_"
		is_sentence = false
	elif q_type == 3:
		while not new_q["is_sentence"]:
			new_q = BIG_SET.pick_random()
		%Tip.text = "Fill the gap!"
		%Question.editable = false
		%Tip.editable = false
		correct_sentence = new_q["original"]
		var word_array = new_q["original"].split(" ")
		var chosen_index = randi_range(0,word_array.size()-1)
		while word_array[chosen_index].length() <= 3:
			chosen_index = randi_range(0,word_array.size()-1)
		if word_array[-1][-1] in ["?", ".","!", ","] and chosen_index == word_array.size()-1:
			word_array.append(word_array[-1][-1])
			word_array[-2][-1] = ""
		
		correct_answer = word_array[chosen_index]
		word_array[chosen_index] = "_" + " _".repeat(correct_answer.length()-1)
		#word_array[chosen_index][-1] = " _ "
		%Question.text = " ".join(word_array)
		points = min(10,correct_answer.length() * 2)
		given_tip = new_q["translation"]
		wrap_question()
		await get_tree().create_timer(2).timeout
		%Tip.text = given_tip
		%Tip.editable = true
		"""
		tip_array = []
		for c in correct_answer:
			if c == " ":
				tip_array.append(" ")
			else:
				tip_array.append(" _")
		tip_array[0] = "_"
		"""
		is_sentence = false
	if question_type !=3:
		wrap_question()
	
func wrap_question():
	print(%Question.text.length())
	if %Question.text.length() > 40:
		var break_index = round(%Question.text.length()/2)
		while %Question.text[break_index] != " "  and break_index < %Question.text.length():
			break_index += 1
		if break_index < %Question.text.length():
			print("INSERT")
			%Question.text = %Question.text.insert(break_index, " \n ")
			

func check():
	var wait_time = max(1,float(correct_answer.length())/10) 
	if question_type in [1,2]:
		if question_type == 2:
			given_tip = %Question.text
			%Tip.text = given_tip
		%Question.text = correct_answer
	elif question_type == 3:
		%Question.text = correct_sentence
	if %Answer.text == correct_answer:
		wait_time = min(3, wait_time)
		%Question.label_settings.font_color = Color.GREEN
		%Tip.label_settings.font_color = Color.GREEN
		if question_type == 1:
			%Tip.text = given_tip
	elif almost_correct():
		wait_time = min(4, wait_time)
		points = max(0, points-1)
		%Question.label_settings.font_color = Color.GREEN_YELLOW
		%Tip.label_settings.font_color = Color.GREEN_YELLOW
		if question_type == 1:
			%Tip.text = given_tip
	elif half_correct():
		points = max(0, points-2)
		%Question.label_settings.font_color = Color.YELLOW
		%Tip.label_settings.font_color = Color.YELLOW
		if question_type == 1:
			%Tip.text = given_tip
	else:
		points = 0
		%Question.label_settings.font_color = Color.RED
		%Tip.label_settings.font_color = Color.RED
	if points > 0:
		%Score.text = "+" + str(points) + "p."
		score += points
	wait_time = 1
	await get_tree().create_timer(wait_time).timeout
	%Question.label_settings.font_color = Color.WHITE
	%Tip.label_settings.font_color = Color.WHITE
	add_question_to_previous()
	new_question()
		

func load_array():
	if not FileAccess.file_exists("user://FiszkiGerman.json"):
		print("File not found!")
		return []
	
	var file = FileAccess.open("user://FiszkiGerman.json", FileAccess.READ)
	var json_string = file.get_as_text()  # Read the file content
	file.close()
	
	var json = JSON.parse_string(json_string)  # Convert JSON back to array
	return json if json is Array else []

func save_array():
	var file = FileAccess.open("user://FiszkiGerman.json", FileAccess.WRITE)
	var json_string = JSON.stringify(BIG_SET)  # Convert array to JSON
	file.store_string(json_string)  # Save to file
	file.close()


func _on_check_button_pressed():
	check()


func _on_answer_text_submitted(_new_text):
	check()


func _on_tip_button_pressed():
	if question_type == 1:
		%Tip.editable = true
	if question_type == 2:
		add_tip()
	if question_type == 3 and %Tip.text == given_tip:
		tip_inside_question()
	%Tip.text = given_tip
	
func tip_inside_question():
	points = max(0, points-2)
	var word_array = %Question.text.split(" ")
	var underline_indexes = []
	for i in range(word_array.size()):
		if word_array[i] == "_":
			underline_indexes.append(i)
	if underline_indexes.size() == 0:
		return
	word_array[underline_indexes[0]] = correct_answer[-underline_indexes.size()]
	%Question.text = " ".join(word_array)


func tip_full():
	for t in tip_array:
		if t in ["_", " _"]:
			return false
	return true

func add_tip():
	points = max(0, points-2)
	if tip_full():
		return
	if given_tip == "":
		tip_array[0] = correct_answer[0]
	else:
		var new_i = randi_range(1,correct_answer.length()-1)
		while tip_array[new_i] != " _":
			new_i = randi_range(1,correct_answer.length()-1)
		tip_array[new_i] = correct_answer[new_i]
	given_tip = "".join(tip_array)
	


func _on_skip_button_pressed():
	new_question()
	
func almost_correct():
	if is_sentence and %Answer.text.capitalize() == correct_answer.capitalize():
		return true
	if correct_answer[-1] in [",",".","?","!"]:
		var temp_ans = correct_answer
		temp_ans[-1] = ""
		if temp_ans == %Answer.text:
			return true
	
func half_correct():
	if not is_sentence:
		if %Answer.text == correct_answer.capitalize():
			given_tip = "First letter shouldn't be big!" 
			return true
		if %Answer.text.capitalize() == correct_answer:
			given_tip = "Remeber about big letter!"
			return true
	var temp_ans = %Answer.text
	for i in range(temp_ans.length()):
		if temp_ans[i].to_lower() == "ö":
			temp_ans[i] = "o" #ÄöÖüÜß
		elif temp_ans[i].to_lower() == "ü":
			temp_ans[i] = "u" #ÄöÖüÜß
		elif temp_ans[i].to_lower() == "ä":
			temp_ans[i] = "a" #ÄöÖüÜß
	var temp_corr_ans = correct_answer
	for i in range(temp_corr_ans.length()):
		if temp_corr_ans[i].to_lower() == "ö":
			temp_corr_ans[i] = "o" #ÄöÖüÜß
		elif temp_corr_ans[i].to_lower() == "ü":
			temp_corr_ans[i] = "u" #ÄöÖüÜß
		elif temp_corr_ans[i].to_lower() == "ä":
			temp_corr_ans[i] = "a" #ÄöÖüÜß
	print(temp_ans)
	print(temp_corr_ans)
	if temp_ans.to_lower() == temp_corr_ans.to_lower():
		given_tip = "Remember about Umlauts!"
		return true
	
	return false
	


func _on_exit_pressed():
	closed.emit()


func _on_save_button_pressed():
	%Score.visible = true
	%QuestionContainer.visible = true
	%SettingsContainer.visible = false
	if question_set_changed:
		new_question()


func _on_settings_button_pressed():
	%Score.visible = false
	%QuestionContainer.visible = false
	%SettingsContainer.visible = true
	%PrevContainer.visible = false


func _on_copy_button_pressed():
	question_set_changed = true
	if %CopyButton.button_pressed:
		question_types.append(1)
	else:
		question_types.erase(1)


func _on_translate_button_pressed():
	question_set_changed = true
	if %TranslateButton.button_pressed:
		question_types.append(2)
	else:
		question_types.erase(2)


func _on_fill_button_pressed():
	question_set_changed = true
	if %FillButton.button_pressed:
		question_types.append(1)
	else:
		question_types.erase(1)



func _on_z_to_y_pressed():
	%Answer.z_to_y = %z_to_y.button_pressed


func _on_ae_to_a_pressed():
	%Answer.ae_to_umlaut = %ae_to_a.button_pressed


func _on_right_umlaufts_pressed():
	%Answer.right_umlauts = %right_umlaufts.button_pressed

func add_question_to_previous():
	var new_q = %PrevQuestion.duplicate()
	new_q.visible = true
	new_q.text = "Q:  " + correct_answer
	var new_a = %PrevAnswer.duplicate()
	new_a.text = "A:  " + %Answer.text
	new_a.visible = true
	var new_b = %PrevBlank.duplicate()
	new_b.visible = true
	%PrevList.add_child(new_q)
	%PrevList.add_child(new_a)
	%PrevList.add_child(new_b)
	%PrevList.move_child(new_b,0)
	%PrevList.move_child(new_a,0)
	%PrevList.move_child(new_q,0)
	



func _on_previous_button_pressed():
	if not %PrevContainer.visible:
		%PreviousButton.text = "Back to Learning"
		%PrevContainer.visible = true
		%Score.visible = false
		%QuestionContainer.visible = false
		%SettingsContainer.visible = false
	else:
		%PreviousButton.text = "Previous Questions"
		%PrevContainer.visible = false
		%Score.visible = true
		%QuestionContainer.visible = true


func _on_question_text_edited(old_text, new_text):
	var is_okay = false
	if question_type == 1:
		for b in BIG_SET:
			if b["original"] == old_text:
				b["original"] = new_text 
				is_okay = true
	elif question_type == 2:
		for b in BIG_SET:
			if b["translation"] == old_text:
				b["translation"] = new_text 
				is_okay = true
	if is_okay:
		save_array()



func _on_tip_text_edited(old_text, new_text):
	var is_okay = false
	for b in BIG_SET:
		if b["translation"] == old_text:
			b["translation"] = new_text 
			is_okay = true
			print(b)

	if is_okay:
		save_array()
