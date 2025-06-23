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
signal closed

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().current_scene == self:
		start()
	pass
	
func start():
	started = true
	reset()
	

func reset():
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
	question_id = 0
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
	question_id = question_id + 1
	if question_id >= word_set.size():
		add_progress()
		question_id = 0
	while word_set[question_id]["is_sentence"]:
		question_id = question_id + 1
		if question_id >= word_set.size():
			add_progress()
			question_id = 0
	%QuestionLabel.text = word_set[question_id]["original"]
	var good_answer = word_set[question_id]["translation"]
	var answers = [good_answer]
	while answers.size()< 4:
		var new_a:String
		if answers_from_the_same_deck:
			new_a = word_set.pick_random()["translation"]
		else:
			var new_aa = Base.SMALL_ARRAY.pick_random()
			while new_aa["is_sentence"]:
				new_aa = Base.SMALL_ARRAY.pick_random()
			new_a = new_aa["translation"]
		if not new_a in answers:
			answers.append(new_a)
	answers.shuffle()
	good_answer_id = answers.find(good_answer)
	%Answer1.text = "1. " + answers[0]
	%Answer2.text = "2. " + answers[1]
	%Answer3.text = "3. " + answers[2]
	%Answer4.text = "4. " + answers[3]

func add_progress():
	for w in word_set:
		if w in progressed_words or not w["is_sentence"]:
			continue
		var index = 0
		for b in Base.SMALL_ARRAY:
			if b["original"] == w["original"]:
				b["weight"] = min(10, w["weight"]+ 4/runda)
		if training_on_new_words:
			for b in Base.BIG_ARRAY:
				if b["original"] == w["original"]:
					b["weight"] = min(4, w["weight"]+ 2/runda)
		progressed_words.append(w)
	runda += 1
	Base.save()
				

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
		return
	if x == good_answer_id:
		done += 1
		word_set[question_id]["is_sentence"] = true
		
		%ScoreLabel.label_settings.font_color = Color.GREEN
		await show_good_answer_correct()
		if done == word_set.size():
			finale()
			return
	else:
		#print("BAD")
		await show_good_answer()
	next_question()
	%ScoreLabel.text = str(done) + "/" + str(word_set.size())

func prepare_set():
	var result = []
	for b in Base.SMALL_ARRAY:
		if b["is_sentence"]:
			continue
		result.append(b)
	print(result.size())
	var result2 = []
	for i in range(10):
		var end = result2.size()>0
		for r in result:
			if r["weight"] <= i and r["weight"]> i -1:
				result2.append(r)
		if end:
			break
	print("prepared", result2.size())
	return result2

func show_good_answer_correct():
	%ScoreLabel.label_settings.font_color = Color.GREEN
	%QuestionLabel.text = %QuestionLabel.text + " = " + word_set[question_id]["translation"]
	await get_tree().create_timer(0.8).timeout
	%ScoreLabel.label_settings.font_color = Color.WHITE
	
func show_good_answer():
	%ScoreLabel.label_settings.font_color = Color.RED
	%QuestionLabel.text = %QuestionLabel.text + " = " + word_set[question_id]["translation"]
	await get_tree().create_timer(1.5).timeout
	%ScoreLabel.label_settings.font_color = Color.WHITE
	
func finale():
	add_progress()
#	print(load_array())
	%Answer1.text = "1. One more time!"
	%Answer2.text = "2. Improve the deck"
	%Answer3.text = "3. Back to Main Menu"
	%Answer4.text = "?"
	finished = true
	%QuestionLabel.text = "GOOD JOB! :D"
	var temp:float = 0
	for b in Base.SMALL_ARRAY:
		if not b["is_sentence"]:
			temp += b["weight"]
	var words_max:float = 0
	for b in Base.SMALL_ARRAY:
		if not b["is_sentence"]:
			words_max += 10
	var percent : float = (temp/words_max) * 100.0
	percent = round(percent * 100)/100
	%ScoreLabel.text = str(percent) + "%"
	
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
		for i in range(Base.BIG_ARRAY.size()):
			var b = Base.BIG_ARRAY[i]
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
		Base.BIG_ARRAY[index]["original"]=record.get_node("HBoxContainer/German").text
		Base.BIG_ARRAY[index]["translation"]=record.get_node("HBoxContainer/English").text
		Base.BIG_ARRAY[index]["weight"]=int(record.get_node("HBoxContainer/Waga").text)
		Base.BIG_ARRAY[index]["is_sentence"]=record.get_node("HBoxContainer/Sentence").button_pressed
		record.queue_free()

	
	Base.save()
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
	
