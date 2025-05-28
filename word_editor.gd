extends VBoxContainer
var BIG_SET : Array
var words_set = []
var only_nouns = false
var total = 0
var done = 0
var current_index = 0
var editing = false
signal closed

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().current_scene == self:
		start()
		
func start():
	BIG_SET = load_array()
	prepare_set()
	next_word(true)
	
func prepare_set():
	var to_do_counter = 0
	var die_das_der_counter = 0
	current_index = 0
	words_set = []
	for i in range(BIG_SET.size()):
		var b = BIG_SET[i]
		if b["is_sentence"]:
			continue
		if b.has("part_of_speech"):
			continue
		if b["original"].split(" ")[0] == "die":
			b["part_of_speech"] = "noun"
			b["gender"] = "female"
			b["is_plural"] = false
			die_das_der_counter += 1
		elif b["original"].split(" ")[0] == "der":
			b["part_of_speech"] = "noun"
			b["gender"] = "male"
			b["is_plural"] = false
			die_das_der_counter += 1
		elif b["original"].split(" ")[0] == "das":
			b["part_of_speech"] = "noun"
			b["gender"] = "neutral"
			b["is_plural"] = false
			die_das_der_counter += 1
		else:
			if only_nouns and b["original"][0].to_lower() == b["original"][0]:
				continue
			to_do_counter += 1
			words_set.append(i)
	print("die_das_der: ", die_das_der_counter)
	print("to_do_counter: ", to_do_counter)
	words_set.shuffle()
	total = words_set.size()
	done = 0

func next_word(first_time=false):
	if not first_time:
		var current_word = BIG_SET[words_set[current_index]]
		current_word["date_modified"] = Time.get_datetime_string_from_system()
		done += 1
		current_index += 1
	%Counter.text = str(done)+"/"+str(total)
	%Word.text = BIG_SET[words_set[current_index]]["original"]
	%Translation.text = BIG_SET[words_set[current_index]]["translation"]	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


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


func _on_female_pressed():
	if editing:
		return
	editing = true
	var current_word = BIG_SET[words_set[current_index]]
	current_word["original"][0] = current_word["original"][0].to_upper()
	current_word["original"] = "die " + current_word["original"]
	current_word["part_of_speech"] = "noun"
	current_word["gender"] = "female"
	current_word["is_plural"] = false
	current_word["is_proper"] = false
	%Word.text = current_word["original"]
	await get_tree().create_timer(0.6).timeout
	next_word()
	editing = false


func _on_male_pressed():
	if editing:
		return
	editing = true
	var current_word = BIG_SET[words_set[current_index]]
	current_word["original"][0] = current_word["original"][0].to_upper()
	current_word["original"] = "der " + current_word["original"]
	current_word["part_of_speech"] = "noun"
	current_word["gender"] = "male"
	current_word["is_plural"] = false
	current_word["is_proper"] = false
	%Word.text = current_word["original"]
	await get_tree().create_timer(0.6).timeout
	next_word()
	editing = false


func _on_neutral_pressed():
	if editing:
		return
	editing = true
	var current_word = BIG_SET[words_set[current_index]]
	current_word["original"][0] = current_word["original"][0].to_upper()
	current_word["original"] = "das " + current_word["original"]
	current_word["part_of_speech"] = "noun"
	current_word["gender"] = "neutral"
	current_word["is_plural"] = false
	current_word["is_proper"] = false
	%Word.text = current_word["original"]
	await get_tree().create_timer(0.6).timeout
	next_word()
	editing = false


func _on_plural_pressed():
	if editing:
		return
	editing = true
	var current_word = BIG_SET[words_set[current_index]]
	current_word["original"][0] = current_word["original"][0].to_upper()
	current_word["part_of_speech"] = "noun"
	current_word["is_proper"] = false
	current_word["is_plural"] = true
	next_word()
	editing = false


func _on_proper_pressed():
	if editing:
		return
	editing = true
	var current_word = BIG_SET[words_set[current_index]]
	current_word["part_of_speech"] = "noun"
	current_word["is_proper"] = true
	current_word["is_plural"] = false
	%Word.text = current_word["original"]
	next_word()
	editing = false


func _on_verb_pressed():
	if editing:
		return
	editing = true
	var current_word = BIG_SET[words_set[current_index]]
	current_word["part_of_speech"] = "verb"
	next_word()
	editing = false


func _on_adjective_pressed():
	if editing:
		return
	editing = true
	var current_word = BIG_SET[words_set[current_index]]
	current_word["part_of_speech"] = "adjective"
	next_word()
	editing = false


func _on_other_pressed():
	if editing:
		return
	editing = true
	var current_word = BIG_SET[words_set[current_index]]
	current_word["part_of_speech"] = "other"
	next_word()
	editing = false


func _on_sentence_pressed():
	if editing:
		return
	editing = true
	var current_word = BIG_SET[words_set[current_index]]
	current_word["is_sentence"] = true
	current_word["original"][0] = current_word["original"][0].to_upper()
	next_word()
	editing = false


func _on_check_box_toggled(button_pressed):
	only_nouns = button_pressed
	prepare_set()
	next_word("true")


func _on_back_pressed():
	if editing:
		return
	save_array()
	closed.emit()
