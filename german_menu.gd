extends Control
signal closed
var day_of_learning : int

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#BIG_SET = Utility.load_array()
	#print(BIG_SET.size())
	
	#for b in BIG_SET:
	#	print(b[4]*0.8)
	#update_day_now()
	update_weights()
	update_disabled_buttons()
	
	#TEST
	var cos = []
	var cos2 = []
	var sth = {"name":"Janusz", "Surname": "XXXXX"}
	cos.append(sth)
	cos2.append(sth)
	print("test ", cos.size(), " ", cos2.size())
	cos2.erase(sth)
	print("test ", cos.size(), " ", cos2.size())

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
			for b in Base.BIG_ARRAY:
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
	%FilterWindow.visible = true


func _on_quit_pressed():
	closed.emit()
	if get_tree().current_scene == self:
		get_tree().quit()


func _on_learn_pressed():
	%MainMenu.visible = false
	%GamesMenu.visible = true
	%FilterWindow.visible = false


func _on_improve_pressed():
	%MainMenu.visible = false
	%EditingMenu.visible = true
	%FilterWindow.visible = false
	



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
	
	


func _on_new_words_pressed():
	%Menus.visible = false
	%Generator.visible = true
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


func _on_word_editor_pressed():
	%Menus.visible = false
	%MainMenu.visible = true
	%EditingMenu.visible = false
	%WordEditor.visible = true
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
	if Base.SMALL_ARRAY.size() == 0:
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
		for b in Base.SMALL_ARRAY:
			if b["is_sentence"]:
				sentences_amount += 1
			else:
				words_amount += 1
		
		%ABCD_Button.disabled = words_amount < 10
		%ABCD_Button.tooltip_text = "Potrzebujesz min. 10 słów by uruchomić tę grę" if words_amount < 10 else ""
		
		var crossword_counter = 0
		for s in Base.SMALL_ARRAY:
			if s["is_sentence"]:
				continue
			if not " " in s["original"] or (s["original"].split(" ").size()<=2 and s["original"].left(3).to_lower() in ["die", "der", "das"]):
				crossword_counter += 1
		
		if crossword_counter > 30:
			%CrosswordButton.disabled = false
			%CrosswordButton.tooltip_text = ""
		else:
			%CrosswordButton.disabled = true
			%CrosswordButton.tooltip_text = "Za mało haseł do krzyżówki"
		
		


func _on_filter_window_edited():
	update_disabled_buttons()
