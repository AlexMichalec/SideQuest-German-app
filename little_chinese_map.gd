extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_add_one_text_submitted(new_text):
	add_record(%AddOneOriginal.text, %AddOne.text, %AddOnePinYin.text)
	%AddOne.text = ""
	%AddOneOriginal.text = ""
	%AddOnePinYin.text = ""
	%AddOneOriginal.grab_focus()

func add_record(orignal : String, translation: String, pinyin :String = ""):
	var new_record = %SampleLabel.duplicate()
	if pinyin == "":
		new_record.text = orignal + " - " + translation
	else:
		new_record.text = orignal + " [" + pinyin.strip_edges() + "] - " + translation
	new_record.visible = true
	%ListContainer.add_child(new_record)

func _on_add_one_original_text_submitted(new_text):
	%AddOnePinYin.grab_focus()


func _on_add_one_button_pressed():
	%AddOneContainer.visible = not %AddOneContainer.visible
	if %AddOneContainer.visible:
		%AddOneOriginal.grab_focus()
		%AddOneOriginal.text = ""
		%AddOne.text = ""
		%AddOnePinYin.text = ""
		%AddMoreContainer.visible = false
		


func _on_submit_more_pressed():
	var original_array = %OrginalMore.text.split("\n")
	var translation_array = %TranslationMore.text.split("\n")
	var pinyin_array = %PinYinMore.text.split("\n")
	if original_array.size() != translation_array.size():
		print("Nierówna ilość wierszy!!")
		return
	for i in range(original_array.size()):
		if original_array[i] == "" or translation_array[i] == "":
			continue
		if i < pinyin_array.size():
			add_record(original_array[i], translation_array[i], pinyin_array[i])
		else:
			add_record(original_array[i], translation_array[i])
	%OrginalMore.text = ""
	%TranslationMore.text = ""
	%PinYinMore.text = ""
	%AddMoreContainer.visible = false


func _on_add_more_button_pressed():
	%AddMoreContainer.visible = not %AddMoreContainer.visible
	%OrginalMore.text = ""
	%TranslationMore.text = ""
	%PinYinMore.text = ""
	%AddOneContainer.visible = false


func _on_list_button_pressed():
	%ListScrollContainer.visible = not %ListScrollContainer.visible


func _on_add_one_pin_yin_text_submitted(new_text):
	%AddOne.grab_focus()
