extends Control
signal closed
var day_of_learning : int

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_first_node_in_group("ProgressBar").update_start()
	update_disabled_buttons()
	%BaseName.text = NewUtility.array_of_bases[0]["name"]
	if OS.get_name() == "Web":
		%Quit.visible = false

	


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
		#print("Ratio")
		#print(ratio)
		if ratio != 1:
			for b in NewUtility.BIG_ARRAY:
				b["weight"] *= ratio
	var save_file = FileAccess.open("user://GermanDate.save", FileAccess.WRITE)
	save_file.store_32(today)
	save_file.close()

	
	
func update_day_now():
	day_of_learning = round(Time.get_unix_time_from_system()/(60*60*24))
 


func _process(delta):
	pass


func _on_back_pressed():
	%MainMenu.visible = true 
	%GamesMenu.visible = false
	%EditingMenu.visible = false
	##%FilterWindow.visible = true


func _on_quit_pressed():
	closed.emit()
	if get_tree().current_scene == self:
		get_tree().quit()


func _on_learn_pressed():
	%MainMenu.visible = false
	%GamesMenu.visible = true
	#%FilterWindow.visible = false


func _on_improve_pressed():
	%MainMenu.visible = false
	%EditingMenu.visible = true
	
	#%FilterWindow.visible = false
	



func _on_abcd_game_closed():
	%Menus.visible = true
	%MainMenu.visible = true
	%GamesMenu.visible = false
	%ABCDGame.visible = false
	NewUtility.SMALL_ARRAY = NewUtility.BIG_ARRAY
	update_disabled_buttons()
	##%FilterWindow.visible = true
	


func _on_abcd_button_pressed():
	%Menus.visible = false
	%MainMenu.visible = true
	%GamesMenu.visible = false
	%ABCDGame.visible = true
	%ABCDGame.training_on_new_words = false
	%ABCDGame.start()


func _on_edit_all_button_pressed():
	%Menus.visible = false
	%MainMenu.visible = true
	%EditingMenu.visible = false
	%EditAll.visible = true
	%EditAll.start()


func _on_edit_all_closed():
	%Menus.visible = true
	%EditAll.visible = false
	##%FilterWindow.visible = true
	
	


func _on_new_words_pressed():
	%Menus.visible = false
	%Generator.visible = true
	%Generator.new_words = []
	#print(NewUtility.BIG_ARRAY)


func _on_generator_closed():
	%Menus.visible = true
	%Generator.visible = false
	NewUtility.SMALL_ARRAY = NewUtility.BIG_ARRAY
	update_disabled_buttons()
	
	##%FilterWindow.visible = true


func _on_generator_test_words():
	%Generator.visible = false
#	%ABCDGame.TEST_SET = %Generator.new_words
	var sentence_counter = 0
	for word in NewUtility.SMALL_ARRAY:
		if word["is_sentence"]:
			sentence_counter += 1
	if sentence_counter == NewUtility.SMALL_ARRAY.size() or NewUtility.SMALL_ARRAY.size()<4:
		%SpellingGame.visible = true
		%SpellingGame.start()
		return
	%ABCDGame.training_on_new_words = true
	%ABCDGame.visible = true
	%ABCDGame.start()
	


func _on_spelling_button_pressed():
	%Menus.visible = false
	%MainMenu.visible = true
	%GamesMenu.visible = false
	%SpellingGame.visible = true
	%SpellingGame.start()


func _on_spelling_game_closed():
	%Menus.visible = true
	%SpellingGame.visible = false
	NewUtility.SMALL_ARRAY = NewUtility.BIG_ARRAY
	update_disabled_buttons()
	##%FilterWindow.visible = true



func _on_crossword_button_pressed():
	%Menus.visible = false
	%MainMenu.visible = true
	%GamesMenu.visible = false
	%Crossword.visible = true
	%Crossword.start()


func _on_crossword_closed():
	%Crossword.visible = false
	%Menus.visible = true
	##%FilterWindow.visible = true


func _on_word_editor_closed():
	%Menus.visible = true
	%WordEditor.visible = false
	##%FilterWindow.visible = true


func _on_word_editor_pressed():
	%Menus.visible = false
	%MainMenu.visible = true
	%EditingMenu.visible = false
	%WordEditor.visible = true
	%WordEditor.start()


func _on_browser_closed():
	%Menus.visible = true
	%Browser.visible = false
	##%FilterWindow.visible = true


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
	##%FilterWindow.visible = true


func _on_cut_sentences_closed():
	%Menus.visible = true
	%CutSentences.visible = false
	##%FilterWindow.visible = true


func _on_cut_sentences_pressed():
	%Menus.visible = false
	%MainMenu.visible = true
	%EditingMenu.visible = false
	%CutSentences.visible = true
	%CutSentences.start()

func update_disabled_buttons():
	if NewUtility.SMALL_ARRAY.size() == 0:
		%Learn.disabled = true
		%Learn.tooltip_text = "The Base is empty"
		%Improve.disabled = true
		%Improve.tooltip_text = "The Base is empty"
	else:
		%Learn.disabled = false
		%Learn.tooltip_text = ""
		%Improve.disabled = false
		%Improve.tooltip_text = ""
		var words_amount = 0
		var sentences_amount = 0
		for b in NewUtility.SMALL_ARRAY:
			if b["is_sentence"]:
				sentences_amount += 1
			else:
				words_amount += 1
		
	#	%ABCD_Button.disabled = words_amount < 10
	#	%ABCD_Button.tooltip_text = "Potrzebujesz min. 10 słów by uruchomić tę grę" if words_amount < 10 else ""
		
		var crossword_counter = 0
		for s in NewUtility.SMALL_ARRAY:
			if s["is_sentence"]:
				continue
			if not " " in s["original"] or (s["original"].split(" ").size()<=2 and s["original"].left(3).to_lower() in ["die", "der", "das"]):
				crossword_counter += 1
		
		if crossword_counter > 25:
			%CrosswordButton.disabled = false
			%CrosswordButton.tooltip_text = ""
		else:
			%CrosswordButton.disabled = true
			%CrosswordButton.tooltip_text = "Not enough words for a crossword!"
	
	var abcd_counter = 0
	for record in NewUtility.SMALL_ARRAY:
		if not record["is_sentence"]:
			abcd_counter += 1
	%ABCD_Button.disabled = abcd_counter<4
	%ABCD_Button.tooltip_text = "" if abcd_counter>=4 else "not enough words"
		


func _on_filter_window_edited():
	update_disabled_buttons()


func _on_load_pressed() -> void:
	NewUtility.save_array()
	get_tree().change_scene_to_file("res://loading_base_screen.tscn")


func _on_abcd_game_to_spelling() -> void:
	%ABCDGame.visible = false
	%SpellingGame.visible = true
	%SpellingGame.start()
	
