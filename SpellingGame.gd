extends VBoxContainer
var correct_answer = ""
var correct_sentence = ""
var question_type = 0
var given_tip = ""
var tip_array = []
var is_sentence = false
var score = 0
var points = 0
var question_types = [1,2,3]
var question_set_changed = false
var questions_to_repeat = []
var current_record = null
signal closed

# Called when the node enters the scene tree for the first time.
func _ready():
	load_settings()
	new_question()
	
	

func start():
	score = 0
	new_question()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func new_question():
	if Base.SMALL_ARRAY.size()==0:
		return
	%Score.text = str(score) + " points"
	points = 10
	%Answer.text = ""
	if question_types.size() == 0:
		question_types = [1, 2, 3]
	var q_type = question_types.pick_random()
	question_type = q_type
	print("q", question_types," qq", question_type)
	var new_q = Base.SMALL_ARRAY.pick_random()
	var gap_id = -1
	print(" ")
	for q in questions_to_repeat:
		print(q[0], "  ", q[1]["original"], "  ", q[2], "  ", "" if q.size() == 3 else q[3])
	
	if questions_to_repeat.size()>0 and questions_to_repeat[0][0] <= 0:
		new_q = questions_to_repeat[0][1]
		q_type = questions_to_repeat[0][2]
		if questions_to_repeat[0].size()>3:
			gap_id = questions_to_repeat[0][3]
		questions_to_repeat.pop_front()
	else:
		for q in questions_to_repeat:
			q[0] -= 1
	if q_type == 1:
		if new_q["is_sentence"]:
			%Tip.text = "Copy the sentence!"
			points = 6
		else:
			%Tip.text = "Copy the word!"
			points = 4
		current_record = new_q
		%Question.text = new_q["original"]
		wrap_question()
		%Question.editable = true
		%Tip.editable = false
		correct_answer = new_q["original"]
		given_tip = new_q["translation"]
		is_sentence = new_q["is_sentence"]
	elif q_type == 2:
		var loop_counter = 0
		while new_q["is_sentence"] and loop_counter < 100:
			new_q = Base.SMALL_ARRAY.pick_random()
			loop_counter += 1
		if loop_counter >= 100:
			new_question()
			return
		current_record = new_q
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
		var loop_counter = 0
		while not new_q["is_sentence"] and loop_counter < 100:
			new_q = Base.SMALL_ARRAY.pick_random()
			loop_counter += 1
		if loop_counter == 100:
			new_question()
			return
		current_record = new_q
		%Tip.text = "Fill the gap!"
		%Question.editable = false
		%Tip.editable = false
		correct_sentence = new_q["original"]
		var word_array = new_q["original"].split(" ")
		var chosen_index = randi_range(0,word_array.size()-1)
		while word_array[chosen_index].length() <= 3:
			chosen_index = randi_range(0,word_array.size()-1)
		if gap_id != -1:
			chosen_index = gap_id 
		if word_array[-1][-1] in ["?", ".","!", ","] and chosen_index == word_array.size()-1:
			word_array.append(word_array[-1][-1])
			word_array[-2][-1] = ""
			if word_array[-2].right(2) == "..":
				word_array[-2][-1] = ""
				word_array[-2][-1] = ""
				word_array[-1] = "..."
		
		correct_answer = word_array[chosen_index]
		word_array[chosen_index] = "_" + " _".repeat(correct_answer.length()-1)
		#word_array[chosen_index][-1] = " _ "
		%Question.text = " ".join(word_array)
		points = min(10,correct_answer.length() * 2)
		given_tip = new_q["translation"]
		wrap_question()
		var t= %Question.text
		await get_tree().create_timer(2).timeout
		if t == %Question.text:
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
	
	
func wrap_question():
	#print(%Question.text.length())
	if %Question.text.length() > 40:
		var break_index = round(%Question.text.length()/2)
		while %Question.text[break_index] != " "  and break_index < %Question.text.length():
			break_index += 1
		if break_index < %Question.text.length():
			%Question.text = %Question.text.insert(break_index, " \n ")
			

func check():
	var wait_time = 1 #max(1,float(correct_answer.length())/10) 
	%Tip.text = current_record["translation"]
	%Question.text = current_record["original"]
	wrap_question()
#	if question_type in [1,2]:
#		if question_type == 2:
#			given_tip = %Question.text
#			%Tip.text = given_tip
#		%Question.text = correct_answer
#	elif question_type == 3:
#		%Question.text = correct_sentence
		
	if %Answer.text == correct_answer:
		%Question.label_settings.font_color = Color.GREEN
		%Tip.label_settings.font_color = Color.GREEN
	elif almost_correct():
		wait_time += 0.5
		points = max(0, points-1)
		%Question.label_settings.font_color = Color.GREEN_YELLOW
		%Tip.label_settings.font_color = Color.GREEN_YELLOW
	elif half_correct():
		wait_time += 1
		add_to_repeat()
		points = max(0, points-2)
		%Question.label_settings.font_color = Color.YELLOW
		%Tip.label_settings.font_color = Color.YELLOW
	else:
		wait_time += 0.5
		add_to_repeat()
		points = 0
		%Question.label_settings.font_color = Color.RED
		%Tip.label_settings.font_color = Color.RED
	if points > 0:
		%Score.text = "+" + str(points) + "p."
		score += points
	await get_tree().create_timer(wait_time).timeout
	%Question.label_settings.font_color = Color.WHITE
	%Tip.label_settings.font_color = Color.WHITE
	add_question_to_previous()
	new_question()
		
func add_to_repeat():
	questions_to_repeat.append([randi_range(5,10),current_record,question_type])
	if question_type == 3:
		var gap_id = current_record["original"].split(" ").find(correct_answer)
		if gap_id == -1:
			var possible_suffixes = [",",".","!","?","...",";",":"]
			for suf in possible_suffixes:
				if gap_id == -1:
					gap_id = current_record["original"].split(" ").find(correct_answer+suf)
		questions_to_repeat[-1].append(gap_id)
	questions_to_repeat.sort()



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
		if correct_answer.left(3) in ["die", "das", "der"]:
			tip_array[1] = correct_answer[1]
			tip_array[2] = correct_answer[2]
			tip_array[4] = correct_answer[4]
	else:
		var new_i = 1
		while tip_array[new_i] != " _":
			new_i += 1
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
	if %Answer.text.split(" ")[0] in ["Die", "Das", "Der"] and not current_record["is_sentence"] and %Answer.text.right(-1) == correct_answer.right(-1):
		return true
	return false
	
func half_correct():
	if not is_sentence:
		if %Answer.text.to_lower() == correct_answer.to_lower() and  %Answer.text != correct_answer:
			var my_answer :String =  %Answer.text
			var temp_correct_answer = correct_answer
			if correct_answer.split(" ")[0].to_lower() in ["die", "das", "der"]:
				my_answer = my_answer.right(-4)
				temp_correct_answer = temp_correct_answer.right(-4)
			if my_answer.capitalize() == temp_correct_answer:
				%Tip.text = "Remeber about big letter!" + "\n\n" + %Tip.text
				return true
			elif my_answer == temp_correct_answer.capitalize():
				%Tip.text = "First letter shouldn't be big!" + "\n\n" + %Tip.text
				return true
			else:
				%Tip.text = "Don't forget about big/small letters!" + "\n\n" + %Tip.text
				return true
#		if %Answer.text == correct_answer.capitalize():
#			%Tip.text = "First letter shouldn't be big!" + "\n" + %Tip.text
#			return true
#		if %Answer.text.capitalize() == correct_answer:
#			%Tip.text = "Remeber about big letter!" + "\n" + %Tip.text
#			return true
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
	#print(temp_ans)
	#print(temp_corr_ans)
	if temp_ans.to_lower() == temp_corr_ans.to_lower():
		%Tip.text = "Remember about Umlauts!" + "\n\n" + %Tip.text
		return true
		
	if not current_record["is_sentence"] and %Answer.text.to_lower() == correct_answer.right(-4).to_lower() and correct_answer.left(3) in ["die", "das","der"]:
		%Tip.text = "Don't forget articles!" + "\n\n" + %Tip.text
		return true
	
	if not current_record["is_sentence"] and %Answer.text.right(-4).to_lower() == correct_answer.right(-4).to_lower() and correct_answer.left(3) in ["die", "das","der"]:
		%Tip.text = "Wrong Article!" + "\n\n" + %Tip.text
		return true
	
	return false
	


func _on_exit_pressed():
	questions_to_repeat = []
	%PreviousButton.text = "Previous Questions"
	%PrevContainer.visible = false
	%Score.visible = true
	%QuestionContainer.visible = true
	%SettingsContainer.visible = false
	closed.emit()


func _on_save_button_pressed():
	%Score.visible = true
	%QuestionContainer.visible = true
	%SettingsContainer.visible = false
	save_settings()
	if question_set_changed:
		for q in questions_to_repeat:
			if q[2] not in question_types:
				questions_to_repeat.erase(q)
		new_question()
	print(question_types)
		


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
	%SaveButton.disabled =( question_types == [])


func _on_translate_button_pressed():
	question_set_changed = true
	if %TranslateButton.button_pressed:
		question_types.append(2)
	else:
		question_types.erase(2)
	%SaveButton.disabled =( question_types == [])


func _on_fill_button_pressed():
	question_set_changed = true
	if %FillButton.button_pressed:
		question_types.append(3)
	else:
		question_types.erase(3)
		
	%SaveButton.disabled =( question_types == [])
	



func _on_z_to_y_pressed():
	%Answer.z_to_y = %z_to_y.button_pressed


func _on_ae_to_a_pressed():
	%Answer.ae_to_umlaut = %ae_to_a.button_pressed


func _on_right_umlaufts_pressed():
	%Answer.right_umlauts = %right_umlaufts.button_pressed

func add_question_to_previous():
	var new_q = %PrevQuestion.duplicate()
	new_q.visible = true
	new_q.text = "[font_size=12]Correct answer:[/font_size]  " + check_misspelling(correct_answer,%Answer.text, true)#correct_answer
	var new_a = %PrevAnswer.duplicate()
	new_a.text = "[font_size=12]Your answer:[/font_size]  " + check_misspelling(%Answer.text, correct_answer, false)
	new_a.visible = true
	var new_b = %PrevBlank.duplicate()
	new_b.visible = true
	%PrevList.add_child(new_q)
	%PrevList.add_child(new_a)
	%PrevList.add_child(new_b)
	%PrevList.move_child(new_b,0)
	%PrevList.move_child(new_a,0)
	%PrevList.move_child(new_q,0)
	

func check_misspelling(answer:String, correct:String, blue:bool):
	if answer.length() == 0 or correct.length() == 0:
		return
	if answer.length() > 20:
		var a_array = answer.split(" ")
		var c_array = correct.split(" ")
		if a_array.size() == c_array.size() and a_array.size()>1:
			var final_result = ""
			for i in range(a_array.size()):
				final_result = final_result + " " + check_misspelling(a_array[i], c_array[i], blue)
			return final_result
	var error_color = "[color=\"red\"]" if not blue else "[color=\"#00a5fe\"]"
	var good_color = "[color=\"white\"]" if blue else "[color=\"light_green\"]"
	var correct_array = []
	for i in range(answer.length()):
		if i >= correct.length():
			correct_array.append(false)
			continue
		correct_array.append(answer[i] == correct[i])
	for i in range(min(correct.length(),answer.length())):
		if correct[-i] == answer[-i]:
			correct_array[-i] =true
	var current_bool = correct_array[0]
	var result = good_color if correct_array[0] else error_color
	for i in range(correct_array.size()):
		if current_bool != correct_array[i]:
			result = result + "[/color]"
			current_bool = correct_array[i]
			result = result + (good_color if correct_array[i] else error_color)
		result = result + answer[i]
	result = result + "[/color]"
	return result
		

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
		for b in Base.BIG_ARRAY:
			if b["original"] == old_text:
				b["original"] = new_text 
				is_okay = true
	elif question_type == 2:
		for b in Base.BIG_ARRAY:
			if b["translation"] == old_text:
				b["translation"] = new_text 
				is_okay = true
	if is_okay:
		Base.save()



func _on_tip_text_edited(old_text, new_text):
	var is_okay = false
	for b in Base.BIG_ARRAY:
		if b["translation"] == old_text:
			b["translation"] = new_text 
			b["date_modified"] = Time.get_datetime_string_from_system()
			is_okay = true
			#print(b)

	if is_okay:
		Base.save()
		
		
func load_settings():
	if not FileAccess.file_exists("user://GermanSpellingSettings.json"):
		print("File not found!")
		%CopyButton.button_pressed = true
		%TranslateButton.button_pressed = true
		%FillButton.button_pressed = true 
		%z_to_y.button_pressed = %Answer.z_to_y
		%ae_to_a.button_pressed = %Answer.ae_to_umlaut 
		%right_umlaufts.button_pressed = %Answer.right_umlauts
		return
	
	var file = FileAccess.open("user://GermanSpellingSettings.json", FileAccess.READ)
	var json_string = file.get_as_text()  # Read the file content
	file.close()
	var settings = JSON.parse_string(json_string)  # Convert JSON back to array
	question_types = settings["question_types"]
	for i in range(question_types.size()):
		question_types[i] = int(question_types[i])
	print("test ", 1 in question_types)
	%CopyButton.button_pressed = 1 in question_types
	%TranslateButton.button_pressed = 2 in question_types
	%FillButton.button_pressed = 3 in question_types
	%z_to_y.button_pressed = settings["german_keyboard"][0]
	%ae_to_a.button_pressed = settings["german_keyboard"][1]
	%right_umlaufts.button_pressed = settings["german_keyboard"][2]
	%Answer.z_to_y = settings["german_keyboard"][0]
	%Answer.ae_to_umlaut = settings["german_keyboard"][1]
	%Answer.right_umlauts = settings["german_keyboard"][2]

func save_settings():
	var file = FileAccess.open("user://GermanSpellingSettings.json", FileAccess.WRITE)
	var settings = {
		"question_types": question_types,
		"german_keyboard": [%Answer.z_to_y, %Answer.ae_to_umlaut, %Answer.right_umlauts]
	}
	var json_string = JSON.stringify(settings)  # Convert array to JSON
	file.store_string(json_string)  # Save to file
	file.close()


func _on_today_pressed():
#	BIG_SET = Filter.by_date(0)
	new_question()


func _on_this_week_pressed():
	var week_ago = date_week_ago()
	print(week_ago)
	var is_okay = true
	#for b in Filter.by_date(load_array(), 0, "",week_ago):
	#	print(b["original"], " ", b["date_added"])
#	BIG_SET = Filter.by_date( 0, "",week_ago)
	


func date_week_ago():
	var week_ago = Time.get_datetime_dict_from_system()
	
	if week_ago["day"] >= 8:
		week_ago["day"] -= 7
	elif week_ago["month"] not in [1,3]:
		week_ago["month"] -= 1
		week_ago["day"] += (31 if week_ago["month"] in [1,3,5,7,8,10,12] else 30) - 7
	elif week_ago["month"] == 3:
		week_ago["month"] -= 1
		week_ago["day"] += (28 if week_ago["year"] % 4 !=0 else 29) - 7
	else:
		week_ago["year"] -= 1
		week_ago["month"] = 12
		week_ago["day"] += 31 - 7
	return Time.get_datetime_string_from_datetime_dict(week_ago, false)


func _on_all_time_pressed():
#	BIG_SET = load_array()
	new_question()
