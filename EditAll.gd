extends Control
var BIG_SET:Array
signal closed
# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().current_scene == self:
		BIG_SET = load_array()
		start()
	
func start():
	#BIG_SET = load_array()
	prepare_records()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func prepare_records():
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
	return a[0].to_lower() < b[0].to_lower()


func _on_save_pressed():
	BIG_SET = []
	for record in %WordsList.get_children():
		if record.get_node("HBoxContainer/German").text == "":
			continue
		if record.get_node("HBoxContainer/Delete").button_pressed:
			record.queue_free()
			continue
		var temp = ["","",false,false,1.5]
		temp[0]=record.get_node("HBoxContainer/German").text
		temp[1]=record.get_node("HBoxContainer/English").text
		temp[4]=int(record.get_node("HBoxContainer/Waga").text)
		temp[2]=record.get_node("HBoxContainer/Sentence").button_pressed
		BIG_SET.append(temp)
		record.queue_free()
	"""
	for b in BIG_SET:
		print(b)
	print(BIG_SET.size())
	"""
	save_array()
	closed.emit()


func _on_cancel_pressed():
	pass # Replace with function body.
	closed.emit()
