extends VBoxContainer
var BIG_SET : Array
var current_record : Dictionary
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
			if o_text.length()>40:
				var counter = round(o_text.length()/2)
				while o_text[counter] != " ":
					counter += 1
				o_text[counter] = "\n"
				o_text = "[right]" + o_text
			if b["original"].to_lower().contains(new_text.to_lower()):
				var index = b["original"].to_lower().find(new_text.to_lower())
				o_text = o_text.insert(index + new_text.length(),"[/bgcolor]")
				o_text = o_text.insert(index,"[bgcolor=black]")
				#print(o_text)
			
			var t_text = b["translation"]
			if t_text.length()>40:
				var counter = round(t_text.length()/2)
				while t_text[counter] != " ":
					counter += 1
				t_text[counter] = "\n"
			if b["translation"].to_lower().contains(new_text.to_lower()):
				var index = b["translation"].to_lower().find(new_text.to_lower())
				t_text = t_text.insert(index + new_text.length(),"[/bgcolor]")
				t_text = t_text.insert(index,"[bgcolor=black]")
				#print(t_text)
			
			new_record.get_node("Original").text = o_text
			new_record.get_node("Translation").text = t_text
			new_record.get_node("Translation/Button").pressed.connect(show_edit_window)
			new_record.get_node("Translation/Button").pressed.connect(func():fill_editor_window(b))
			new_record.get_node("Translation/Button").position.x +=  60
			new_record.visible = true
			%RecordLists.add_child(new_record)
			
func edit_button():
	print("EDIT")
	
	
func fill_editor_window(word : Dictionary):
	print(word)
	current_record = word
	%ScrollCategoriesBox.scroll_vertical = 0
	for child in %CategoriesContainer.get_children():
		if child is CheckButton:
			child.button_pressed = false
	%MainCat.button_pressed = true
	%OriginalEdit.text = word["original"]
	%TranslationEdit.text = word["translation"]
	%SentenceEdit.button_pressed = word["is_sentence"]
	%WeightEdit.text = str(word["weight"])
	%WordContainer.visible = not word["is_sentence"]
	%Added.text = "Added: " + word["date_added"].split("T")[0]
	if word.has("date_modified"):
		%Modified.text = "Modified: " + word["date_modified"].split("T")[0]
		%Modified.visible = true
	else:
		%Modified.visible = false
	if word["is_sentence"]:
		%NounContainer.visible = false
		%PartOfSpeech.select(-1)
		%PluralButton.button_pressed = false
		%ProperButton.button_pressed = false
		%GenderButton.select(-1)
		return
	if word.has("part_of_speech"):
		%PartOfSpeech.selected = {"noun":0,"adjective":1,"verb":2, "other":3}[word["part_of_speech"]]
	else:
		%PartOfSpeech.selected = -1
		%PluralButton.button_pressed = false
		%ProperButton.button_pressed = false
		%NounContainer.visible = false
		%GenderButton.select(-1)
		return
	if word["part_of_speech"] == "noun":
		%NounContainer.visible = true
		%ProperButton.button_pressed = word.has("is_proper") and word["is_proper"]
		%PluralButton.button_pressed = word.has("is_plural") and word["is_plural"]
		if not word.has("gender"):
			%GenderButton.selected = -1
		else:
			%GenderButton.selected = {"female" : 0, "male": 1, "neutral": 2}[word["gender"]]
		if %PluralButton.button_pressed or %ProperButton.button_pressed:
			%GenderButton.selected = -1
			%GenderButton.disabled = true
		
		
		
		
		
	else:
		%NounContainer.visible = false
	


func _on_button_pressed():
	save_array()
	$LineEdit.text = ""
	for child in %RecordLists.get_children():
		if child != %SampleRecord:
			child.queue_free()
	closed.emit()


func _on_sentence_edit_toggled(button_pressed):
	%WordContainer.visible = not button_pressed
	




func _on_proper_button_toggled(button_pressed):
	if button_pressed:
		%GenderButton.disabled = true
		%GenderButton.select(-1)
	elif not %PluralButton.button_pressed:
		%GenderButton.disabled = false



func _on_plural_button_toggled(button_pressed):
	if button_pressed:
		%GenderButton.disabled = true
		%GenderButton.select(-1)
	elif not %ProperButton.button_pressed:
		%GenderButton.disabled = false


func _on_part_of_speech_item_selected(index):
	%NounContainer.visible = index == 0


func _on_gender_button_item_selected(index):
	if %OriginalEdit.text.split(" ")[0].to_lower() in ["die", "das", "der"]:
		%OriginalEdit.text = %OriginalEdit.text.right(-4)
	var article = ["die", "der", "das"][index]
	%OriginalEdit.text = article + " " + %OriginalEdit.text
	if %TranslationEdit.text.split(" ")[0].to_lower() != "the":
		%TranslationEdit.text = "The " + %TranslationEdit.text


func _on_save_pressed():
	save_record()
	show_browse_window()


func _on_cancel_pressed():
	show_browse_window()
	
func show_browse_window():
	%BrowsingContainer.visible = true
	%EditingContainer.visible = false
	%Back.visible = true
	%Cancel.visible = false
	%Save.visible = false
	$LineEdit.visible = true
	%BrowsingPanel.visible = true
	

func show_edit_window():
	%BrowsingContainer.visible = false
	%EditingContainer.visible = true
	%Back.visible = false
	%Cancel.visible = true
	%Save.visible = true
	$LineEdit.visible = false
	%BrowsingPanel.visible = false
	
func save_record():
	current_record["original"] = %OriginalEdit.text
	current_record["translation"] = %TranslationEdit.text 
	current_record["weight"] = float(%WeightEdit.text)
	current_record["is_sentence"] = %SentenceEdit.button_pressed 
	current_record["date_modified"] = Time.get_datetime_string_from_system()
	if %PartOfSpeech.selected != -1:
		current_record["part_of_speech"] = ["noun", "adjective", "verb", "other"][%PartOfSpeech.selected]
	else:
		print("NS",current_record)
		return
	if %PluralButton.button_pressed:
		current_record["is_plural"] = true
	elif current_record.has("is_plural"):
		current_record["is_plural"] = false
	if %ProperButton.button_pressed:
		current_record["is_proper"] = true
	elif current_record.has("is_proper"):
		current_record["is_proper"] = false
	if %GenderButton.selected != -1:
		current_record["gender"] = ["female", "male", "neutral"][%GenderButton.selected]
	print("S",current_record)
