extends VBoxContainer

var word_set: Array
var question_id: int
var good_answer_id: int
var done :int
var finished = false
var answers_from_the_same_deck = false
var runda = 1
var progressed_words = []
var editing = false
var started = false
var training_on_new_words = false
var reverse_question = false
var progressed_words_total = []
signal closed
signal to_spelling

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().current_scene == self:
		start()
	pass
	
func start():
	started = true
	progressed_words_total = []
	reset()
	

func reset():
	$Back.visible = true
	for word in progressed_words:
		if not word in progressed_words_total:
			progressed_words_total.append(word)
	progressed_words = []
	runda = 1
	finished = false
	var big_set :Array = prepare_set()
	word_set = []
	var break_counter =0
	while word_set.size() < min(10, big_set.size()) and break_counter < 100:
		var new_q = big_set.pick_random()
		if not new_q["is_sentence"] and not new_q in word_set:
			word_set.append(new_q.duplicate())
		break_counter += 1
	question_id = -1
	done = 0
	%ScoreLabel.text = "0/" + str(word_set.size())
	next_question()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not started:
		return
	if Input.is_action_just_pressed("1"):
		check(0)
	if Input.is_action_just_pressed("2"):
		check(1)
	if Input.is_action_just_pressed("3"):
		check(2)
	if Input.is_action_just_pressed("4"):
		check(3)
	pass
	
func next_question():
	#print("q",question_id, "  R", runda)
	question_id = question_id + 1
	if question_id >= word_set.size():
		#add_progress()
		runda += 1
		question_id = 0
	while word_set[question_id]["is_sentence"]:
		question_id = question_id + 1
		if question_id >= word_set.size():
			runda += 1
			question_id = 0
	reverse_question = [true,false].pick_random()
	%QuestionLabel.text = word_set[question_id]["translation"] if reverse_question else word_set[question_id]["original"]
	var good_answer = word_set[question_id]["original"] if reverse_question else word_set[question_id]["translation"]
	var answers = [good_answer]
	while answers.size()< 4:
		var new_a:String
		if answers_from_the_same_deck:
			new_a = word_set.pick_random()["original"] if reverse_question else word_set.pick_random()["translation"]
		else:
			var new_aa = NewUtility.SMALL_ARRAY.pick_random()
			while new_aa["is_sentence"]:
				new_aa = NewUtility.SMALL_ARRAY.pick_random()
			new_a = new_aa["original"] if reverse_question else new_aa["translation"]
		if not new_a in answers:
			answers.append(new_a)
	answers.shuffle()
	good_answer_id = answers.find(good_answer)
	var answer_buttons = [%Answer1, %Answer2,%Answer3, %Answer4]
	for i in range(4):
		answer_buttons[i].tooltip_text = str(i+1) + ". " + answers[i]
		answer_buttons[i].text = str(i+1) + ". " + answers[i]
		if answers[i].length() > 20:
			answer_buttons[i].text = str(i+1) + ". " + answers[i].left(18) + "..."
	"""%Answer1.text = "1. " + answers[0]
	%Answer2.text = "2. " + answers[1]
	%Answer3.text = "3. " + answers[2]
	%Answer4.text = "4. " + answers[3]"""
func add_weight():
	var w = word_set[question_id]
	for b in NewUtility.SMALL_ARRAY:
			if b["original"] == w["original"]:
				b["weight"] = min(10, w["weight"]+ 4/runda)
	progressed_words.append(w)
	get_tree().get_first_node_in_group("ProgressBar").update()
	
func add_progress():	#OLD?
	for w in word_set:
		if w in progressed_words or not w["is_sentence"]:
			continue
		var index = 0
		for b in NewUtility.SMALL_ARRAY:
			if b["original"] == w["original"]:
				b["weight"] = min(10, w["weight"]+ 4/runda)
		if training_on_new_words:
			for b in NewUtility.BIG_ARRAY:
				if b["original"] == w["original"]:
					b["weight"] = min(4, w["weight"]+ 2/runda)
		progressed_words.append(w)
	runda += 1
	NewUtility.save_array()
				

func check(x:int):
	if editing:
		if x == 0:
			cancel_editing()
		if x == 1:
			save_edited()
		return
	if finished:
		if x == 0:
			reset()
		if x ==1:
			start_modifying()
		if x == 2:
			closed.emit()
			started = false
			finished = false
		if x == 3:
			if NewUtility.SMALL_ARRAY == NewUtility.BIG_ARRAY:
				NewUtility.SMALL_ARRAY = []
				for word in progressed_words:
					#print(word)
					if not word in progressed_words_total:
						progressed_words_total.append(word)
						#print("OK")
				for word in progressed_words_total:
					for record in NewUtility.BIG_ARRAY:
						if record["original"] == word["original"]:
							NewUtility.SMALL_ARRAY.append(record)
				#print(NewUtility.SMALL_ARRAY)
				#NewUtility.SMALL_ARRAY = progressed_words
			to_spelling.emit()
			started = false
			finished = false
			
			
		return
	if x == good_answer_id:
		add_weight()
		done += 1
		word_set[question_id]["is_sentence"] = true
		%ScoreLabel.text = str(done) + "/" + str(word_set.size())
		%ScoreLabel.label_settings.font_color = Color.SPRING_GREEN
		await show_good_answer_correct()
		if done == word_set.size():
			finale()
			return
	else:
		#print("BAD")
		await show_good_answer()
	next_question()
	
func prepare_set():
	var result = []
	for b in NewUtility.SMALL_ARRAY:
		if b["is_sentence"]:
			continue
		result.append(b)
	#print(result.size())
	var result2 = []
	for i in range(10):
		var end = result2.size()>0
		for r in result:
			if r["weight"] <= i and r["weight"]> i -1:
				result2.append(r)
		if end:
			break
	#print("prepared", result2.size())
	return result2

func show_good_answer_correct():
	%ScoreLabel.label_settings.font_color = Color.SPRING_GREEN
	%QuestionLabel.text = %QuestionLabel.text + " = " + (word_set[question_id]["translation"] if not reverse_question else word_set[question_id]["original"] ) 
	await get_tree().create_timer(0.8).timeout
	%ScoreLabel.label_settings.font_color = Color.WHITE
	
func show_good_answer():
	%ScoreLabel.label_settings.font_color = Color.RED
	%QuestionLabel.text = %QuestionLabel.text + " = " + (word_set[question_id]["translation"] if not reverse_question else word_set[question_id]["original"] )
	await get_tree().create_timer(1.5).timeout
	%ScoreLabel.label_settings.font_color = Color.WHITE
	
func finale():
	add_progress()
#	print(load_array())
	%Answer1.text = "1. One more time!"
	%Answer2.text = "2. Improve the deck"
	%Answer3.text = "3. Back to Main Menu"
	%Answer4.text = "4. Test your Spelling!"
	$Back.visible = false
	finished = true
	%QuestionLabel.text = ["GOOD JOB! :D"].pick_random()
	#if runda == 1:
	#	%QuestionLabel.text = ["CONGRATULATION, YOU ARE "].pick_random()
	var temp:float = 0
	for b in NewUtility.SMALL_ARRAY:
		if not b["is_sentence"]:
			temp += b["weight"]
	var words_max:float = 0
	for b in NewUtility.SMALL_ARRAY:
		if not b["is_sentence"]:
			words_max += 10
	var percent : float = (temp/words_max) * 100.0
	percent = round(percent * 100)/100
	%ScoreLabel.text = ""
	#%ScoreLabel.text = str(percent) + "%"
	
func start_modifying():
	%ScrollModifyContainer.visible = true
	%ModifyWordsContainr.visible = true
	%ScoreLabel.visible = false
	%QuestionLabel.visible = false
	%Answer1.text = "Cancel editing"
	%Answer2.text = "SAVE"
	for w in word_set:
		var new_record = %EditWord.duplicate()
		new_record.visible = true
		%ModifyWordsContainr.add_child(new_record)
		new_record.get_node("HBoxContainer/German").text = w["original"]
		new_record.get_node("HBoxContainer/English").text = w["translation"]
		for i in range(NewUtility.BIG_ARRAY.size()):
			var b = NewUtility.BIG_ARRAY[i]
			if b["original"] == w["original"]:
				new_record.get_node("HBoxContainer/Index").text = str(i)
				new_record.get_node("HBoxContainer/Waga").text = str(b["weight"])
				new_record.get_node("HBoxContainer/Sentence").button_pressed = b["is_sentence"]
	editing = true
	finished = false
	
func cancel_editing():
	%ScrollModifyContainer.visible = false
	%ModifyWordsContainr.visible = false
	%ScoreLabel.visible = true
	%QuestionLabel.visible = true
	%Answer1.text = "1. One more round!"
	%Answer2.text = "2. Modify"
	for record in %ModifyWordsContainr.get_children():
		if record.get_node("HBoxContainer/German").text == "":
			continue
		record.queue_free()
	finished = true
	editing = false
	
func save_edited():
	%ScrollModifyContainer.visible = false
	%ModifyWordsContainr.visible = false
	%ScoreLabel.visible = true
	%QuestionLabel.visible = true
	%Answer1.text = "1. One more round!"
	%Answer2.text = "2. Modify"
	for record in %ModifyWordsContainr.get_children():
		if record.get_node("HBoxContainer/German").text == "":
			continue
		var index = int(record.get_node("HBoxContainer/Index").text)
		NewUtility.BIG_ARRAY[index]["original"]=record.get_node("HBoxContainer/German").text
		NewUtility.BIG_ARRAY[index]["translation"]=record.get_node("HBoxContainer/English").text
		NewUtility.BIG_ARRAY[index]["weight"]=int(record.get_node("HBoxContainer/Waga").text)
		NewUtility.BIG_ARRAY[index]["is_sentence"]=record.get_node("HBoxContainer/Sentence").button_pressed
		record.queue_free()

	
	NewUtility.save_array()
	finished = true
	editing = false
		

func _on_answer_1_pressed():
	check(0)

func _on_answer_2_pressed():
	check(1)

func _on_answer_3_pressed():
	check(2)

func _on_answer_4_pressed():
	check(3)
	


func _on_back_pressed() -> void:
	closed.emit()
	started = false
	finished = false
