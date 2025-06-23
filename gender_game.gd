extends Panel
var gender_set :Array
var showing_answer = false
var score = 0
var questions_amount = 10
var keep_seen_words = false
var seen_words = []
var settings_not_saved = false

signal closed
# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().current_scene == self:
		start()
	for b in Base.BIG_ARRAY:
		if b.has("gender") and not b["part_of_speech"] == "noun":
			b
			print(b["original"], " - ", b["translation"])

func start():
	load_settings()
	seen_words = []
	prepare_set()
	new_question()
	score = 0
	
func prepare_set():
	if not keep_seen_words:
		reset_done()
	gender_set = []
	for b in Base.BIG_ARRAY:
		if b.has("gender") and not b["is_sentence"] and b.has("part_of_speech") and b["part_of_speech"] == "noun":
			gender_set.append(b)
	print(gender_set.size())
	gender_set.shuffle()
	if questions_amount != -1:
		gender_set = gender_set.slice(0,questions_amount)
	score = 0
	%Score.text = "0/" + str(gender_set.size())
	%finish_buttons.visible = false
	%answer_buttons.visible = true

func new_question():
	var o_text = gender_set[0]["original"]
	if o_text[0].to_lower() == "d":
		o_text = o_text.right(-4)
	%Original.text = o_text
	%Translation.text = gender_set[0]["translation"]
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func show_win():
	%Original.text = "Congratulation!"
	%Translation.text = "You finished the exercise :D"
	%finish_buttons.visible = true
	%answer_buttons.visible = false

func correct_answer():
	print("RICHTIG")
	showing_answer = true
	%Original.text = gender_set[0]["original"]
	%Original.label_settings.font_color = Color.LIME_GREEN
	add_to_done(gender_set[0])
	gender_set.pop_front()
	score+=1
	%Score.text = str(score) + "/" + str(gender_set.size() + score)
	await  get_tree().create_timer(0.6).timeout
	if gender_set.size() > 0:
		new_question()
	else:
		show_win()
	%Original.label_settings.font_color = Color.WHITE
	showing_answer = false
	
	
func wrong_answer():
	print("FALSCH")
	showing_answer = true
	%Original.text = gender_set[0]["original"]
	%Original.label_settings.font_color = Color.RED
	gender_set.insert(min(gender_set.size(),randi_range(5,10)),gender_set[0])
	gender_set.pop_front()
	await get_tree().create_timer(1).timeout
	%Original.label_settings.font_color = Color.WHITE
	new_question()
	showing_answer = false

func _on_female_pressed():
	if showing_answer:
		return
	if gender_set[0]["gender"] == "female":
		correct_answer()
	else:
		wrong_answer()


func _on_male_pressed():
	if showing_answer:
		return
	if gender_set[0]["gender"] == "male":
		correct_answer()
	else:
		wrong_answer()


func _on_neutral_pressed():
	if showing_answer:
		return
	if gender_set[0]["gender"] == "neutral":
		correct_answer()
	else:
		wrong_answer()


func _on_show_questions_pressed():
	%ScrollResuts.visible = true
	%QuestionContainer.visible = false
	%SettingsContainer.visible = false


func _on_settings_pressed():
	%ScrollResuts.visible = false
	%QuestionContainer.visible = false
	%SettingsContainer.visible = true


func _on_one_more_time_pressed():
	%ScrollResuts.visible = false
	%SettingsContainer.visible = false
	%QuestionContainer.visible = true
	if settings_not_saved:
		save_settings()
	settings_not_saved = false
	prepare_set()
	new_question()
	%Show_questions.visible = true
	%Settings.visible = true
	%Settings2.visible = true

func _on_back_pressed():
	%ScrollResuts.visible = false
	%SettingsContainer.visible = false
	%QuestionContainer.visible = true
	if settings_not_saved:
		save_settings()
	settings_not_saved = false
	closed.emit()
	
func reset_done():
	for child in %FemaleContainer.get_children():
		if child != %FemaleSample:
			child.queue_free()
	for child in %MaleContainer.get_children():
		if child != %MaleSample:
			child.queue_free()
	for child in %NeutralContainer.get_children():
		if child != %NeutralSample:
			child.queue_free()

func add_to_done(word:Dictionary):
	if keep_seen_words:
		if word in seen_words:
			return
	
	seen_words.append(word)
	var new_button :Button
	if word["gender"] == "female":	
		new_button = %FemaleSample.duplicate()
		new_button.text = word["original"]
		new_button.visible = true
		%FemaleContainer.add_child(new_button)
	elif word["gender"] == "male":
		new_button = %MaleSample.duplicate()
		new_button.text = word["original"]
		new_button.visible = true
		%MaleContainer.add_child(new_button)
	if word["gender"] == "neutral":
		new_button = %NeutralSample.duplicate()
		new_button.text = word["original"]
		new_button.visible = true
		%NeutralContainer.add_child(new_button)
	
	new_button.mouse_entered.connect(func():new_button.text = word["translation"])
	new_button.mouse_exited.connect(func():new_button.text = word["original"])	


func _on_que_num_slider_drag_ended(value_changed):
	questions_amount = [10,15,20,30,-1][%QueNumSlider.value]
	print(%QueNumSlider.value)
	if value_changed:
		settings_not_saved = true


func _on_keep_words_toggled(button_pressed):
	keep_seen_words = button_pressed
	settings_not_saved = true
	if not button_pressed:
		seen_words = []

func load_settings():
	if not FileAccess.file_exists("user://GenderGameSettings.json"):
		print("File not found!")
		return []
	
	var file = FileAccess.open("user://GenderGameSettings.json", FileAccess.READ)
	var json_string = file.get_as_text()  # Read the file content
	file.close()
	var json = JSON.parse_string(json_string)  # Convert JSON back to array
	keep_seen_words = json["keep_words"]
	%KeepWords.button_pressed = keep_seen_words
	questions_amount = int(json["questions_amount"])
	%QueNumSlider.value = {10:0,15:1,20:2,30:3,-1:4}[questions_amount]
	
func save_settings():
	var file = FileAccess.open("user://GenderGameSettings.json", FileAccess.WRITE)
	var settings = {
		"keep_words": keep_seen_words,
		"questions_amount": questions_amount
	}
	
	var json_string = JSON.stringify(settings)  # Convert array to JSON
	file.store_string(json_string)  # Save to file
	file.close()


func _on_settings_2_pressed():
	%QuestionContainer.visible = false
	%SettingsContainer.visible = true
	%answer_buttons.visible = false
	%Settings2.visible = false
	%save_settings_button.visible = true
	


func _on_save_settings_button_pressed():
	%save_settings_button.visible = false
