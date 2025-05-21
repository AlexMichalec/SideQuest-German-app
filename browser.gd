extends VBoxContainer
var BIG_SET : Array
signal closed
# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().current_scene == self:
		start()

func start():
	BIG_SET = load_array()




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

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




func _on_line_edit_text_changed(new_text):
	for child in %RecordLists.get_children():
		if child != %SampleRecord:
			child.queue_free()
	if new_text.length() < 2:
		return
	"""
	for c in new_text:
		var new_record = %SampleRecord.duplicate()
		new_record.get_node("Original").text = c
		new_record.get_node("Translation").text = c
		new_record.visible = true
		%RecordLists.add_child(new_record)
	"""
	for b in BIG_SET:
		if new_text.to_lower() in b["original"].to_lower() or new_text.to_lower() in b["translation"].to_lower():
			var new_record = %SampleRecord.duplicate()
			var o_text = b["original"]
			if b["original"].to_lower().contains(new_text.to_lower()):
				var index = b["original"].to_lower().find(new_text.to_lower())
				o_text = o_text.insert(index + new_text.length(),"[/bgcolor]")
				o_text = o_text.insert(index,"[bgcolor=black]")
				#print(o_text)
			var t_text = b["translation"]
			if b["translation"].to_lower().contains(new_text.to_lower()):
				var index = b["translation"].to_lower().find(new_text.to_lower())
				t_text = t_text.insert(index + new_text.length(),"[/bgcolor]")
				t_text = t_text.insert(index,"[bgcolor=black]")
				#print(t_text)
			new_record.get_node("Original").text = o_text
			new_record.get_node("Translation").text = t_text
			new_record.get_node("Button").pressed.connect(edit_button)
			new_record.visible = true
			%RecordLists.add_child(new_record)
			
func edit_button():
	print("EDIT")
	

	
	


func _on_button_pressed():
	closed.emit()
