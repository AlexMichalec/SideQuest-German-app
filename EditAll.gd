extends Control
var current_step = 100
var to_delete = []
var change_to_abc = false
var change_to_date = false
signal closed
# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().current_scene == self:
		start()
	
		
	
func start():
	NewUtility.BIG_ARRAY.sort_custom(case_insensitive_sort)
	#var to_del = []
	#for i in range(NewUtility.BIG_ARRAY.size()-1):
	#	if NewUtility.BIG_ARRAY[i]["original"] == NewUtility.BIG_ARRAY[i+1]["original"]:
	#		to_del.append(NewUtility.BIG_ARRAY[i])
	#print("do usunięcia: ", to_del.size())
	to_delete = []
	#for d in to_del:
	#	NewUtility.BIG_ARRAY.erase(d)
	#NewUtility.save_array()
	set_default_step()
	#prepare_option_button()
	get_stats()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_stats():
	var sentences_count = 0
	for record in NewUtility.BIG_ARRAY:
		if record["is_sentence"]:
			sentences_count += 1
	%Stats.text = "Total: " + str(NewUtility.BIG_ARRAY.size()) + ":   Sentences: " + str(sentences_count) + "   Words: " + str(NewUtility.BIG_ARRAY.size() - sentences_count)


func prepare_option_button(step=100):
	%OptionButton.clear()
	var levels = round(NewUtility.BIG_ARRAY.size()/step)
	if NewUtility.BIG_ARRAY.size()%step == 0:
		levels -= 1
	for i in range(levels):
		var first_letter = get_first_letter(NewUtility.BIG_ARRAY[i*step])
		var last_letter = get_first_letter(NewUtility.BIG_ARRAY[(i+1)*step-1])
		var text = str(i*step+1) + "-" + str((i+1)*step) + "  " + first_letter + "-" + last_letter
		%OptionButton.add_item(text)
	var first_letter = get_first_letter(NewUtility.BIG_ARRAY[levels*step])
	var last_letter = get_first_letter(NewUtility.BIG_ARRAY[-1])
	var text = str(levels*step+1) + "-" + str(NewUtility.BIG_ARRAY.size()) + "  " + first_letter + "-" + last_letter
	%OptionButton.add_item(text)

func get_first_letter(record):
	if record["original"].split(" ")[0].to_upper() in ["DIE", "DAS", "DER"]:# and not record["is_sentence"]:
		return record["original"].split(" ")[1][0].to_upper()
	return record["original"][0].to_upper()

func close_old_records():
	var x = %WordsList.get_child_count()
	for child in %WordsList.get_children():
		if child == %NewWord:
			continue
		var record = child
		var index = int(record.get_node("HBoxContainer/Index").text.rstrip("."))-1
		NewUtility.BIG_ARRAY[index]["original"] = record.get_node("HBoxContainer/German").text
		NewUtility.BIG_ARRAY[index]["translation"]=record.get_node("HBoxContainer/English").text
		NewUtility.BIG_ARRAY[index]["weight"] =int(record.get_node("HBoxContainer/Waga").text)
		NewUtility.BIG_ARRAY[index]["is_sentence"] =record.get_node("HBoxContainer/Sentence").button_pressed
		if record.get_node("HBoxContainer/Delete").button_pressed:
			to_delete.append(index)
		elif index in to_delete:
			to_delete.erase(index)
		child.queue_free()
	return

func prepare_records_new(start_id:int, end_id:int):
	close_old_records()
	if change_to_abc:
		NewUtility.BIG_ARRAY.sort_custom(case_insensitive_sort)
		change_to_abc = false
	if change_to_date:
		NewUtility.BIG_ARRAY.sort_custom(date_sort)
		change_to_date = false
	
	for i in range(start_id, end_id):
		var b = NewUtility.BIG_ARRAY[i]
		var new_record = %NewWord.duplicate()
		new_record.visible = true
		%WordsList.add_child(new_record)
		new_record.get_node("HBoxContainer/Index").text = str(i+1) + "."
		new_record.get_node("HBoxContainer/German").text = b["original"]
		new_record.get_node("HBoxContainer/English").text = b["translation"]
		new_record.get_node("HBoxContainer/Waga").text = str(b["weight"])
		new_record.get_node("HBoxContainer/Sentence").button_pressed = b["is_sentence"]
		new_record.get_node("HBoxContainer/Delete").button_pressed = i in to_delete
		new_record.get_node("HBoxContainer/DateLabel").text = b["date_added"].left(10)

func prepare_records_old():
	NewUtility.BIG_ARRAY.sort_custom(case_insensitive_sort)
	var doubles = []
	var sentences_count = 0
	for b in NewUtility.BIG_ARRAY:
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
	%Stats.text = str(NewUtility.BIG_ARRAY.size()) + ":   Sentences: " + str(sentences_count) + "   Words: " + str(NewUtility.BIG_ARRAY.size() - sentences_count)+"   Doubles:" + str(NewUtility.BIG_ARRAY.size() - doubles.size())



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
	#print("SAVE")
	to_delete.sort()
	to_delete.reverse()
	for d_index in to_delete:
		NewUtility.BIG_ARRAY.erase(NewUtility.BIG_ARRAY[d_index])
	NewUtility.save_array()
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
	prepare_records_new(index*current_step, min(NewUtility.BIG_ARRAY.size(),(index+1) * current_step))
	%ScrollContainer.scroll_vertical = 0
	
func set_default_step():
	#print(NewUtility.BIG_ARRAY.size())
	if NewUtility.BIG_ARRAY.size() < 80:
		_on_step_button_item_selected(0)
	elif NewUtility.BIG_ARRAY.size() < 300:
		_on_step_button_item_selected(1)
	elif NewUtility.BIG_ARRAY.size() < 1000:
		_on_step_button_item_selected(2)
	elif NewUtility.BIG_ARRAY.size() < 2000:
		_on_step_button_item_selected(3)
	else:
		_on_step_button_item_selected(4)


func _on_sort_button_item_selected(index):
	if index == 0:
		change_to_abc = true
		_on_option_button_item_selected(0)

		
	elif index == 1:
		change_to_date = true
		_on_option_button_item_selected(0)

		
func date_sort(record_a, record_b):
	return record_a["date_added"] > record_b["date_added"]
