extends Control
var bases_array : Array
var chosen = -1
var editing = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%CancelButton.visible = NewUtility.array_of_bases.size() == 0
	%NewBaseWindow.visible = false
	%DeleteButton.disabled = true
	%EditButton.disabled = true
	%LoadButton.disabled = true
	bases_array = NewUtility.array_of_bases
	"""
	var tab = []
	for i in range(8):
		var base_name = ["baza", "słówka", "vocabulary"].pick_random() + str(randi_range(2,59))
		var language = ["english", "german", "polish"].pick_random()
		var nat_lang = ["english", "german", "polish"].pick_random()
		var records_number = randi_range(0,40) #Pamiętać o pustej
		var base_base = []
		for ii in range(records_number):
			base_base.append(Base.BIG_ARRAY.pick_random())
		tab.append({"name" : base_name, "language":language,"nat_lang":nat_lang,"base_base":base_base, "description":"It's a random base for testing"})
	bases_array = tab
	"""
	for i in range (bases_array.size()):
		var new_butt :Button
		new_butt = %SampleBaseButton.duplicate()
		new_butt.visible = true
		%BasesList.add_child(new_butt)
		new_butt.text = bases_array[i]["name"]
		new_butt.pressed.connect(_base_chosen.bind(new_butt))
	pass # Replace with function body.
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _base_chosen(button_picked):
	var i = %BasesList.get_children().find(button_picked)
	%EditButton.disabled = false
	%DeleteButton.disabled = false
	%LoadButton.disabled = false
	chosen = i
	%NameA.text = bases_array[i]["name"]
	#%LangA.text = bases_array[i]["language"]
	%NumA.text = str(int(bases_array[i]["size"]))
	%DescriptionA.text = bases_array[i]["description"]
	for child in %SampleList.get_children():
		if child == %SampleRecord:
			continue
		child.queue_free()
	for s in bases_array[i]["samples"]:
		var new_rec = %SampleRecord.duplicate()
		new_rec.text = s
		new_rec.visible = true
		%SampleList.add_child(new_rec)
	"""
	var base = bases_array[i]["base_base"]
	base.shuffle()
	for ii in range(min(30,base.size())):
		var new_rec = %SampleRecord.duplicate()
		new_rec.text = base[ii]["original"] + " - " + base[ii]["translation"]
		new_rec.visible = true
		%SampleList.add_child(new_rec)
	if base.size()>30:
		var new_rec = %SampleRecord.duplicate()
		new_rec.text = ". . . and more . . ."
		new_rec.visible = true
		%SampleList.add_child(new_rec)
	"""
			


func _on_delete_button_pressed() -> void:
	%AreYouSureWindow.visible = true
	
	


func _on_load_button_pressed() -> void:
	NewUtility.move_base_to_front(chosen)
	NewUtility.load_array()
	NewUtility.save_main()
	get_tree().change_scene_to_file("res://german_menu.tscn")


func _on_new_base_button_pressed() -> void:
	%TitleNew.text = "Creating New Base:"
	%ErrorLabel.text = ""
	%NameInput.text = ""
	%DescInput.text = ""
	%NewBaseWindow.visible = true
	


func _on_name_a_pressed() -> void:
	%InputA.placeholder_text = %NameA.text
	%InputA.text = ""
	%InputA.visible = true
	%NameA.visible = false
	
	


func _on_input_a_text_submitted(new_text: String) -> void:
	%InputA.visible = false
	%NameA.visible = true
	if %InputA.text == "":
		return
	%NameA.text = %InputA.text
	%BasesList.get_children()[chosen].text = %InputA.text


func _on_cancel_button_pressed() -> void:
	get_tree().change_scene_to_file("res://german_menu.tscn")


func _on_new_cancel_pressed() -> void:
	%NewBaseWindow.visible = false
	editing = false


func _on_new_save_pressed() -> void:
	if check_errors():
		return
	if editing:
		%NameA.text = %NameInput.text
		%DescriptionA.text = %DescInput.text
		for child in %BasesList.get_children():
			if child.button_pressed:
				child.text = %NameInput.text
		bases_array[chosen]["name"] =  %NameInput.text
		bases_array[chosen]["description"] = %DescInput.text
		editing = false
		%NewBaseWindow.visible = false
		return
	if chosen != -1:
		%BasesList.get_children()[chosen].button_pressed = false
	%NewBaseWindow.visible = false
	NewUtility.new_base(%NameInput.text, %DescInput.text)
	var new_butt :Button
	new_butt = %SampleBaseButton.duplicate()
	new_butt.visible = true
	%BasesList.add_child(new_butt)
	%BasesList.move_child(new_butt,0)
	new_butt.text = %NameInput.text
	new_butt.pressed.connect(_base_chosen.bind(new_butt))
	%ScrollContainer.scroll_vertical=0
	chosen = 0
	new_butt.button_pressed = true
	new_butt.pressed.emit()

func check_errors():
	if %NameInput.text.strip_edges() == "":
		%ErrorLabel.text = "Base's name cannot be empty!"
		return true
	for b in NewUtility.array_of_bases:
		if b["name"] == %NameInput.text:
			if editing and NewUtility.array_of_bases.find(b) == chosen:
				continue
			%ErrorLabel.text = "That name is already used!"
			return true	


func _on_edit_button_pressed() -> void:
	editing = true
	%TitleNew.text = "Editing Existing Base"
	%ErrorLabel.text = ""
	%NameInput.text = bases_array[chosen]["name"]
	%DescInput.text = bases_array[chosen]["description"]
	%NewBaseWindow.visible = true


func _on_yes_sure_pressed() -> void:
	%AreYouSureWindow.visible = false
	if %BasesList.get_children()[chosen] == %SampleBaseButton:
		print("MEH")
	%BasesList.get_children()[chosen].queue_free()
	
	%NameA.text = "xxxxxxxx"
	%NumA.text = "xxxxxxxx"
	%DescriptionA.text = ""
	for child in %SampleList.get_children():
		if child == %SampleRecord:
			continue
		child.queue_free()
		
	bases_array.remove_at(chosen)
	chosen = -1
	%DeleteButton.disabled = true
	%LoadButton.disabled = true
	%EditButton.disabled = true


func _on_no_sure_pressed() -> void:
	%AreYouSureWindow.visible = false


func _on_yes_sure_reset_pressed() -> void:
	NewUtility.reset()
	get_tree().reload_current_scene()


func _on_no_sure_reset_pressed() -> void:
	%AreYouSureResetWindow.visible = false


func _on_reset_button_pressed() -> void:
	%AreYouSureResetWindow.visible = true


func _on_info_layer_tree_entered() -> void:
	pass # Replace with function body.
