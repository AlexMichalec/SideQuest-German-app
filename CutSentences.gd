extends Control
var existing_words: Array
var ignored_words: Array
var sentence_array: Array
var current_index = 0
var current_button :Button
signal closed

# Called when the node enters the scene tree for the first time.
func _ready():
	
	start()
	
func start():
	current_index = 0
	prepare_arrays()
	prepare_sentence(sentence_array[0]["original"], sentence_array[0]["translation"])
	
func prepare_arrays():
	sentence_array = []
	ignored_words = load_words_to_ignore()
	if ignored_words == []:
		ignored_words = [".","...","?","!",","]
		ignored_words.append_array(["und", "was", "wie", "wo","ich","ist", "ein", "eine", "einen", "einem", "die", "das", "der", "des", "dem", "den", "ich", "du", "er", "sie", "es", "wir", "ihr"])
	existing_words = []
	for b in Base.BIG_ARRAY:
		if b["is_sentence"]:
			if not b.get("already_cut", false):
				sentence_array.append(b)
			continue
		if b["original"].to_lower() in existing_words:
			continue
		var word = b["original"].to_lower()
		if word.split(" ")[0] in ["die", "der", "das"]:
			word = word.right(-4)
		existing_words.append(word)
	#print("Existings words: ", existing_words.size())
	#for i in range(20):
	#	print(existing_words.pick_random())
	sentence_array.shuffle()
	
func prepare_sentence(sentence:String, translation:String):
	%Progress.text = str(current_index) + "/" + str(sentence_array.size())
	if %SentenceContainer.get_child_count() > 2:
		add_rest_to_ignored()
	var new_array = sentence.split(" ")
	if new_array[-1][-1] in ".,?!":
		new_array.append(new_array[-1][-1])
		if new_array[-2][-2] == "." and new_array[-2][-3] == ".":
			new_array[-1] = "..."
			new_array[-2] = new_array[-2].left(-3)
		else:
			new_array[-2] = new_array[-2].left(-1)
	for i in range(new_array.size()):
		if new_array[i][-1] == "," and new_array[i].length() > 1:
			new_array[i] = new_array[i].left(-1)
			new_array.insert(i+1,",")
	#print(new_array)
	
	#Cleaning SentenceContainr
	for child in %SentenceContainer.get_children():
		if child == %SampleLabel or child == %SampleButton:
			continue
		child.queue_free()
	
	var has_button = false
	for word in new_array:
		if word.to_lower() in existing_words or word.to_lower() in ignored_words:
			var new_label = %SampleLabel.duplicate()
			new_label.text = word
			new_label.visible = true
			%SentenceContainer.add_child(new_label)
		else:
			has_button = true
			var new_button = %SampleButton.duplicate()
			new_button.text = word
			new_button.visible = true
			new_button.mouse_entered.connect(func():make_similar_words(word))
			new_button.mouse_exited.connect(func():erase_similar_words())
			new_button.pressed.connect(func():show_word_edit(word))
			%SentenceContainer.add_child(new_button)
	%SentenceTranslation.text = translation
	if not has_button:
		print("Sentence without a word to add")
		return false
	return true
			
func add_rest_to_ignored():
	for child in %SentenceContainer.get_children():
		if child is Button and child != %SampleLabel and child != %SampleButton:
			ignored_words.append(child.text.to_lower())
	ignored_words.sort()
	#print(ignored_words)
	
func make_similar_words(word:String):
	var temp_array = []
	var max = 0
	for w in existing_words:
		var temp = 0
		while temp<w.length() and temp<word.length() and word[temp].to_lower() == w[temp].to_lower():
			temp += 1
		if max < temp:
			max = temp
		if temp > 2:
			temp_array.append([w,temp])
	if word.left(2) == "ge":
		word = word.right(-2)
		for w in existing_words:
			var temp = 0
			while temp<w.length() and temp<word.length() and word[temp] == w[temp]:
				temp += 1
			if max < temp:
				max = temp
			if temp > 2:
				temp_array.append([w,temp])
	
	var result = " "
	for t in temp_array:
		if t[1] < max:
			continue
		if result != " ":
			result = result + ", "
		result = result + t[0]
	%SimilarWordsList.text = result
	if %SimilarWordsList.text != " ":
		%SimilarWordsLabel.text = "Similar Words:"
	
func erase_similar_words():
	%SimilarWordsList.text = " "
	%SimilarWordsLabel.text = " "
	
func show_word_edit(word:String):
	for child in %SentenceContainer.get_children():
		if child.text == word:
			child.disabled = true
			current_button = child
	%WordEditContainer.visible = true
	%SentenceContainer.visible = false
	%TranslationEdit.text = ""
	%OriginalEdit.text = word
	%Menu.disabled = true
	%NextSentence.disabled = true
	
func hide_word_edit():
	%WordEditContainer.visible = false
	%SentenceContainer.visible = true
	%Menu.disabled = false
	%NextSentence.disabled = false


func set_already_cut(sentence):
	for b in Base.BIG_ARRAY:
		if b == sentence:
			b["already_cut"] = true
			print("OK")
			Base.save()
			return true
	return false

func _process(_delta):
	pass
			

func add_word_to_database(word_type):
	%SimilarWordsLabel.text = " "
	%SimilarWordsList.text = " "
	if %TranslationEdit.text == "":
		%SimilarWordsLabel.text = "You have to add translation first!"
		return
	var word = %OriginalEdit.text 
	var translation = %TranslationEdit.text
	var part_of_speech = "noun" if word_type in ["male", "female", "neutral", "proper"] else word_type
	var gender = word_type if word_type in ["male", "female", "neutral"] else "none"
	if gender == "male":
		if word.left(3).to_lower() in ["die", "der", "das"]:
			word = word.right(-4)
		word = "der " + word.capitalize()
		if translation.left(3).to_lower() != "the":
			translation = "the " + translation
	elif gender == "female":
		if word.left(3).to_lower() in ["die", "der", "das"]:
			word = word.right(-4)
		word = "die " + word.capitalize()
		if translation.left(3).to_lower() != "the":
			translation = "the " + translation
	elif gender == "neutral":
		if word.left(3).to_lower() in ["die", "der", "das"]:
			word = word.right(-4)
		word = "das " + word.capitalize()
		if translation.left(3).to_lower() != "the":
			translation = "the " + translation
	elif part_of_speech == "verb" and translation.left(2)!="to" and not "ć" in translation:
		translation = "to " + translation
	var new_record = {
		"original": word, 
		"translation": translation,
		"date_added": Time.get_datetime_string_from_system(),
		"is_sentence": false,
		"weight": 0,
		"is_plural": false,
		"is_proper": word_type=="proper",
		"part_of_speech": part_of_speech,
		"gender": gender
	}
	print(new_record)
	Base.BIG_ARRAY.append(new_record)
	%SimilarWordsLabel.text = " "
	hide_word_edit()
	Base.save()
	%SimilarWordsLabel.text = "Added:"
	%SimilarWordsList.text = word + " - " + translation
	await get_tree().create_timer(2).timeout
	if %SimilarWordsLabel.text == "Added:":
		%SimilarWordsLabel.text = " "
		%SimilarWordsList.text = " "

func _on_cancel_pressed():
	current_button.disabled = false
	hide_word_edit()


func _on_female_pressed():
	add_word_to_database("female")


func _on_verb_pressed():
	add_word_to_database("verb")


func _on_male_pressed():
	add_word_to_database("male")


func _on_adjective_pressed():
	add_word_to_database("adjective")


func _on_neutral_pressed():
	add_word_to_database("neutral")


func _on_other_pressed():
	add_word_to_database("other")


func _on_proper_pressed():
	add_word_to_database("proper")


func _on_next_sentence_pressed():
	set_already_cut(sentence_array[current_index])
	current_index += 1
	while not prepare_sentence(sentence_array[current_index]["original"],sentence_array[current_index]["translation"]) :
		set_already_cut(sentence_array[current_index])
		current_index += 1
	save_words_to_ignore()
		
func load_words_to_ignore():
	if not FileAccess.file_exists("user://GermanIgnoreWords.json"):
		print("File not found!")
		return []
	
	var file = FileAccess.open("user://GermanIgnoreWords.json", FileAccess.READ)
	var json_string = file.get_as_text()  # Read the file content
	file.close()
	
	var json = JSON.parse_string(json_string)  # Convert JSON back to array
	return json if json is Array else []

func save_words_to_ignore():
	var file = FileAccess.open("user://GermanIgnoreWords.json", FileAccess.WRITE)
	var json_string = JSON.stringify(ignored_words)  # Convert array to JSON
	file.store_string(json_string)  # Save to file
	file.close()


func _on_menu_pressed():
	closed.emit()
	pass # Replace with function body.

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Użytkownik kliknął X – zamykanie aplikacji")
		
		
