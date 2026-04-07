extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Panel.visible = false
	%ButtonInfo.text = "?"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_info_pressed() -> void:
	if $Panel.visible:
		$Panel.visible = false
		%ButtonInfo.text = "?"
	else:
		$Panel.visible = true
		%ButtonInfo.text = "X"

	

func _on_loading_base_screen_ready() -> void:
	if OS.get_name() == "Web":
		%Content.text = "Here you can load an existing base or create completely new one!
		
		This app main functionality is to help you store long lists of words with as little effort as possible, so each new base is empty and can be filled with vocabulary that YOU need!
		
		Unfortunately Itchio doesn't support copy-pastying, so to experience the full potential of the app please downloadd a desktop version, if you can't do it now you can test the app in web version. Just chose one of existing bases and click load!" 
	else:
		%Content.text = "Here you can load an existing base or create completely new one!
		
		This app main functionality is to help you store long lists of words with as little effort as possible, so each new base is empty and can be filled with vocabulary that YOU need!
		
		The app was created mainly as my personal tool to learn German and therefore its fuctions are mainly set for german-learners, but you can still use it for other languages with latin alphabet, just omit gender game/tools" 


func _on_main_menu_draw() -> void:
	if NewUtility.BIG_ARRAY.size() ==0:
		%Content.text = "This is your new base, it is still empty so you got to add some vocabulary first, to do it press [new words] or change vocabulary base by clicking [change base]."
	else:
		%Content.text = "This is main menu, from here you can reach all important features of the app. 

You can add new vocabulary, test your current knowledge and learn new words or edit existing base, so it better fits your needs."



func _on_abcd_game_draw() -> void:
	%Content.text = "Simple game, where you match a correct translation to the word or the word to translation.
	
	If you notice an error in spelling you can correct it right after the round by clicking [Improve the Base].
	
	You can press buttons or use keyboard keys 1-4. The words you see are based on how good you know them, when you feel done with this part you can move on to spelling game. "


func _on_spelling_game_draw() -> void:
	%Content.text = "Here you can train your writing skills.
	
In Settings you can change your German keyboards settings and types of questions you wanna try (copy text, fill blank and translate)"


func _on_crossword_draw() -> void:
	%Content.text = "This is something for fans of retro style puzzles. Train your language knowledge by typing matching words horizontally and vertically.

You can choose where to start writing by clicking number of definition on your keyboard. 

If you feel your memory is not good enough you can press tip to see the words used in this crossword, but have in mind that you'll receive less points then.

Remember to click Check Crossword to score the points before generating a new crosswords.
"


func _on_gender_game_draw() -> void:
	%Content.text = "Noun genders can be tricky, especially in German. If you often forget what articles should be used for tables or windows, that game is definitely for you. 

You can press 1-3 on keyboard to choose a correct article faster. Use settings to personalize the experience so the game suits you better.

Keep in mind that sometimes in case of plural forms nouns can be mis-matched with genders, to correct it go to improve base section of main menu and choose browser or edit all."


func _on_generator_draw() -> void:
	%Content.text = "This is a place where you can add new vocabulary. It's designed to be as effortlessly as possible. You can paste whole list of words (seperated by \" - \") or if you use Google translate or similar website you can paste originals and translations separately. 

In the second step you can make sure all definitions match correct words and mark sentences. (App automatically flag as a sentence every record that is four words or longer) 

At the end you can go straight to practice to test your current knowledge, add more words or come back to main menu, whatever works for you best. 
"

func _on_edit_all_draw() -> void:
	%Content.text = "Here you can overwiew your whole vocabulary base and edit basic parameters of any record. It's an easy to way make sure there are no spelling errors, all sentences are marked correctly and delete words you're not longer interested in learning. 
	
	You can sort records alphabeticaly or by date of adding. If you want more detailed view, come back to section \"Improve Base\" and choose [Browser]
"
func _on_browser_draw() -> void:
	%Content.text = "Here you can search for a particular word or sentence  in order to edit it.
	
	You can search by original word/sentence or translation.
	
	To improve performance of the Browser it starts showing results after typeing in at least three letters."

func _on_cut_sentences_draw() -> void:
	%Content.text = "Our app let you save not only single words, but also whole sentences. Sometimes you might find yourself wanting to include one of the words in ur sentences into ur vocabulary base. That's what this tool is for.
	
	The app automaticaly saves words you chose to ignore, so you can focus on the new ones and those worth learning."

func _on_word_editor_draw() -> void:
	%Content.text = "Here you can set word's characteristic one by one. For now it's mostly used for adding gender to nouns, so you can practice it in the [Gender Game], but in future we might add more games based on these characteristics like irregular verbs or building sentences. 
	
	By clicking [only potential nouns] the app will only show you words that start with capital letters (as all German nouns do). Dont't worry if you made a mistake, you can always change it using [Search for specific word] functionality."
