extends Control
var BIG_SET:Array
var current_step = 100
var to_delete = []
signal closed
# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().current_scene == self:
		BIG_SET = load_array()
		start()
		
	
func start():
	BIG_SET.sort_custom(case_insensitive_sort)
	to_delete = []
	#BIG_SET = load_array()
	#prepare_records()
	set_default_step()
	#prepare_option_button()
	get_stats()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_stats():
	var sentences_count = 0
	for record in BIG_SET:
		if record["is_sentence"]:
			sentences_count += 1
	%Stats.text = "Total: " + str(BIG_SET.size()) + ":   Sentences: " + str(sentences_count) + "   Words: " + str(BIG_SET.size() - sentences_count)


func prepare_option_button(step=100):
	%OptionButton.clear()
	var levels = round(BIG_SET.size()/step)
	if BIG_SET.size()%step == 0:
		levels -= 1
	for i in range(levels):
		var first_letter = get_first_letter(BIG_SET[i*step])
		var last_letter = get_first_letter(BIG_SET[(i+1)*step-1])
		var text = str(i*step+1) + "-" + str((i+1)*step) + "  " + first_letter + "-" + last_letter
		%OptionButton.add_item(text)
	var first_letter = get_first_letter(BIG_SET[levels*step])
	var last_letter = get_first_letter(BIG_SET[-1])
	var text = str(levels*step+1) + "-" + str(BIG_SET.size()) + "  " + first_letter + "-" + last_letter
	%OptionButton.add_item(text)

func get_first_letter(record):
	if record["original"].split(" ")[0].to_upper() in ["DIE", "DAS", "DER"]:# and not record["is_sentence"]:
		return record["original"].split(" ")[1][0].to_upper()
	return record["original"][0].to_upper()

func close_old_records():
	for child in %WordsList.get_children():
		if child == %NewWord:
			continue
		var record = child
		var index = int(record.get_node("HBoxContainer/Index").text.rstrip("."))-1
		BIG_SET[index]["original"] = record.get_node("HBoxContainer/German").text
		BIG_SET[index]["translation"]=record.get_node("HBoxContainer/English").text
		BIG_SET[index]["weight"] =int(record.get_node("HBoxContainer/Waga").text)
		BIG_SET[index]["is_sentence"] =record.get_node("HBoxContainer/Sentence").button_pressed
		if record.get_node("HBoxContainer/Delete").button_pressed:
			to_delete.append(index)
		elif index in to_delete:
			to_delete.erase(index)
		child.queue_free()

func prepare_records_new(start_id:int, end_id:int):
#	BIG_SET.sort_custom(case_insensitive_sort)
#	var doubles = []
#	var sentences_count = 0
	close_old_records()
	for i in range(start_id, end_id):
		var b = BIG_SET[i]
		var new_record = %NewWord.duplicate()
		new_record.visible = true
		%WordsList.add_child(new_record)
		new_record.get_node("HBoxContainer/Index").text = str(i+1) + "."
		new_record.get_node("HBoxContainer/German").text = b["original"]
		new_record.get_node("HBoxContainer/English").text = b["translation"]
		new_record.get_node("HBoxContainer/Waga").text = str(b["weight"])
		new_record.get_node("HBoxContainer/Sentence").button_pressed = b["is_sentence"]
		new_record.get_node("HBoxContainer/Delete").button_pressed = i in to_delete

#		if b[2]:
#			sentences_count += 1
#		new_record.get_node("HBoxContainer/Delete").button_pressed = b[0].to_lower().strip_edges() in doubles
#		if not b[0].to_lower().strip_edges() in doubles:
#			doubles.append(b[0].to_lower().strip_edges())
#	%Stats.text = str(BIG_SET.size()) + ":   Sentences: " + str(sentences_count) + "   Words: " + str(BIG_SET.size() - sentences_count)+"   Doubles:" + str(BIG_SET.size() - doubles.size())

func prepare_records_old():
	BIG_SET.sort_custom(case_insensitive_sort)
	var doubles = []
	var sentences_count = 0
	for b in BIG_SET:
		var new_record = %NewWord.duplicate()
		new_record.visible = true
		%WordsList.add_child(new_record)
		new_record.get_node("HBoxContainer/German").text = b[0]
		new_record.get_node("HBoxContainer/English").text = b[1]
		new_record.get_node("HBoxContainer/Waga").text = str(b[4])
		new_record.get_node("HBoxContainer/Sentence").button_pressed = b[2]
		if b[2]:
			sentences_count += 1
		new_record.get_node("HBoxContainer/Important").button_pressed = b[3]
		new_record.get_node("HBoxContainer/Delete").button_pressed = b[0].to_lower().strip_edges() in doubles
		if not b[0].to_lower().strip_edges() in doubles:
			doubles.append(b[0].to_lower().strip_edges())
	%Stats.text = str(BIG_SET.size()) + ":   Sentences: " + str(sentences_count) + "   Words: " + str(BIG_SET.size() - sentences_count)+"   Doubles:" + str(BIG_SET.size() - doubles.size())

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

func case_insensitive_sort(a, b):
	var a_word : String = a["original"]
	if a_word.split(" ")[0].to_upper() in ["DIE", "DAS", "DER"]:
		a_word = a_word.right(-4)
		
	var b_word = b["original"]
	if b_word.split(" ")[0].to_upper() in ["DIE", "DAS", "DER"]:
		b_word = b_word.right(-4)
	return a_word.to_lower() < b_word.to_lower()


func _on_save_pressed():
	close_old_records()
	print("SAVE")
	to_delete.sort()
	to_delete.reverse()
	for d_index in to_delete:
		BIG_SET.erase(BIG_SET[d_index])
	save_array()
	closed.emit()


func _on_cancel_pressed():
	pass # Replace with function body.
	closed.emit()


func _on_step_button_pressed():
	pass


func _on_step_button_item_selected(index):
	%StepButton.select(index)
	var step = int(%StepButton.get_item_text(index))
	current_step = step
	prepare_option_button(step)
	_on_option_button_item_selected(0)


func _on_option_button_item_selected(index):
	prepare_records_new(index*current_step, min(BIG_SET.size(),(index+1) * current_step))
	%ScrollContainer.scroll_vertical = 0
	
func set_default_step():
	#print(BIG_SET.size())
	if BIG_SET.size() < 80:
		_on_step_button_item_selected(0)
	elif BIG_SET.size() < 300:
		_on_step_button_item_selected(1)
	elif BIG_SET.size() < 1000:
		_on_step_button_item_selected(2)
	elif BIG_SET.size() < 2000:
		_on_step_button_item_selected(3)
	else:
		_on_step_button_item_selected(4)
