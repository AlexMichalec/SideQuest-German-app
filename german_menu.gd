extends Control
signal closed
var BIG_SET : Array
var day_of_learning : int

# Called when the node enters the scene tree for the first time.
func _ready():
	
	BIG_SET = load_array()
	
	
	"""
	var new_set_array = []
	for b in BIG_SET:
		var original = b[0]
		if original.split(" ")[0].to_upper() in ["DIE", "DAS", "DER"]:
			original[0] = original[0].to_lower()
		var new_record = {"original":b[0], "translation":b[1], "weight":b[4], "is_sentence":b[2]}
		new_set_array.append(new_record)
	for i in range(30):
		print(new_set_array[i])
	BIG_SET = new_set_array
	save_array()
	"""
	#for b in BIG_SET:
	#	print(b[4]*0.8)
	#update_day_now()
	update_weights()

func update_weights():
	var today = round(Time.get_unix_time_from_system()/(60*60*24))
	if FileAccess.file_exists("user://GermanDate.save"):
		var last_day_file = FileAccess.open("user://GermanDate.save", FileAccess.READ)
		var last_day = last_day_file.get_32()
		last_day_file.close()
		var days_between = (today - last_day)
		var ratio = 1
		for d in range(days_between):
			ratio = ratio * 0.9
		ratio = round(ratio*100)/100
		print("Ratio")
		print(ratio)
		if ratio != 1:
			for b in BIG_SET:
				b["weight"] *= ratio
	var save_file = FileAccess.open("user://GermanDate.save", FileAccess.WRITE)
	save_file.store_32(today)
	save_file.close()

	
	
func update_day_now():
	day_of_learning = round(Time.get_unix_time_from_system()/(60*60*24))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_back_pressed():
	%MainMenu.visible = true 
	%GamesMenu.visible = false
	%EditingMenu.visible = false


func _on_quit_pressed():
	closed.emit()
	if get_tree().current_scene == self:
		get_tree().quit()


func _on_learn_pressed():
	%MainMenu.visible = false
	%GamesMenu.visible = true


func _on_improve_pressed():
	%MainMenu.visible = false
	%EditingMenu.visible = true
	
	
func save_array():
	var file = FileAccess.open("user://FiszkiGermanSafe.json", FileAccess.WRITE) #"user://FiszkiGermanSafe.json",
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



func _on_abcd_game_closed():
	%Menus.visible = true
	%MainMenu.visible = true
	%GamesMenu.visible = false
	%ABCDGame.visible = false
	


func _on_abcd_button_pressed():
	%Menus.visible = false
	%MainMenu.visible = true
	%GamesMenu.visible = false
	%ABCDGame.visible = true
	%ABCDGame.training_on_new_words = false
	%ABCDGame.BIG_SET = BIG_SET
	%ABCDGame.start()


func _on_edit_all_button_pressed():
	%Menus.visible = false
	%MainMenu.visible = true
	%EditingMenu.visible = false
	%EditAll.visible = true
	%EditAll.BIG_SET = BIG_SET
	%EditAll.start()


func _on_edit_all_closed():
	%Menus.visible = true
	%EditAll.visible = false
	BIG_SET = %EditAll.BIG_SET
	#for i in range(BIG_SET.size()):
	#	print(i, " ", BIG_SET[i])
	
	


func _on_new_words_pressed():
	%Menus.visible = false
	%Generator.visible = true
	%Generator.BIG_SET = BIG_SET
	%Generator.new_words = []


func _on_generator_closed():
	%Menus.visible = true
	%Generator.visible = false


func _on_generator_test_words():
	%Generator.visible = false
	%ABCDGame.TEST_SET = %Generator.new_words
	%ABCDGame.training_on_new_words = true
	%ABCDGame.visible = true
	%ABCDGame.start()
	


func _on_spelling_button_pressed():
	%Menus.visible = false
	%MainMenu.visible = true
	%GamesMenu.visible = false
	%SpellingGame.visible = true
	%SpellingGame.BIG_SET = BIG_SET
	%SpellingGame.start()


func _on_spelling_game_closed():
	%Menus.visible = true
	%SpellingGame.visible = false



func _on_crossword_button_pressed():
	%Menus.visible = false
	%MainMenu.visible = true
	%GamesMenu.visible = false
	%Crossword.visible = true
	%Crossword.start()


func _on_crossword_closed():
	%Crossword.visible = false
	%Menus.visible = true


func _on_word_editor_closed():
	%Menus.visible = true
	%WordEditor.visible = false
	BIG_SET = %WordEditor.BIG_SET


func _on_word_editor_pressed():
	%Menus.visible = false
	%MainMenu.visible = true
	%EditingMenu.visible = false
	%WordEditor.visible = true
	%WordEditor.BIG_SET = BIG_SET
	%WordEditor.start()


func _on_browser_closed():
	%Menus.visible = true
	%Browser.visible = false


func _on_browser_pressed():
	%Menus.visible = false
	%MainMenu.visible = true
	%EditingMenu.visible = false
	%Browser.visible = true
	%Browser.start()


func _on_genders_button_pressed():
	%Menus.visible = false
	%MainMenu.visible = true
	%GamesMenu.visible = false
	%GenderGame.visible = true
	%GenderGame.start()


func _on_gender_game_closed():
	%Menus.visible = true
	%GenderGame.visible = false


func _on_cut_sentences_closed():
	%Menus.visible = true
	%CutSentences.visible = false


func _on_cut_sentences_pressed():
	%Menus.visible = false
	%MainMenu.visible = true
	%EditingMenu.visible = false
	%CutSentences.visible = true
	%CutSentences.start()

func update_disabled_buttons():
	if BIG_SET.size() == 0:
		%Learn.disabled = true
		%Learn.tooltip_text = "Baza słów jest pusta"
		%Improve.disabled = true
		%Improve.tooltip_text = "Baza słów jest pusta"
	else:
		%Learn.disabled = false
		%Learn.tooltip_text = ""
		%Improve.disabled = false
		%Improve.tooltip_text = ""
		var words_amount = 0
		var sentences_amount = 0
		for b in BIG_SET:
			if b["is_sentence"]:
				sentences_amount += 1
			else:
				words_amount += 1
		
		%ABCD_Button.disabled = words_amount < 10
		%ABCD_BUtton.tooltip_text = "Potrzebujesz min. 10 słów by uruchomić tę grę" if words_amount < 10 else ""
		
		
func load_basic_base():
	if not FileAccess.file_exists("BasicBase.json"):
		print("File not found!")
		return []
	
	var file = FileAccess.open("BasicBase.json", FileAccess.READ)
	var json_string = file.get_as_text()  # Read the file content
	file.close()
	
	var json = JSON.parse_string(json_string)  # Convert JSON back to array
	return json if json is Array else []
	
func save_basic_base():
	var file = FileAccess.open("BasicBase.json", FileAccess.WRITE)
	var json_string = JSON.stringify(BIG_SET)  # Convert array to JSON
	file.store_string(json_string)  # Save to file
	file.close()
