extends Control
var lang_array = ["English", "Polish", "German", "Chinese", "Russian", "Spanish", "Other"]
var themes_array = [
  "Animals",
  "Vegetables",
  "Fruits",
  "Emotions",
  "Actions & Verbs",
  "Places & Locations",
  "Time & Dates",
  "Weather & Nature",
  "Body & Health",
  "Clothing & Accessories",
  "Technology & Media",
  "Travel & Transportation"
]
var a = 0
var b = 0

var word_categories = {
	"Animals": [["	kot	","	cat	","	Die Katze	"],
				["	pies	","	dog	","	Der Hund	"],
				["	chomik	","	hamster	","	Der Hamster	"],
				["	koń	","	horse	","	Das Pferd	"],
				["	papuga	","	parrot	","	Der Papagei	"],
				["	ptak	","	bird	","	Der Vogel	"],
				["	małpa	","	monkey	","	Der Affe	"],
				["	lew	","	lion	","	Der Löwe	"],
				["	koza	","	goat	","	Die Ziege	"],
				["	owca	","	sheep	","	Das Schaf	"],
				["	krowa	","	cow	","	Die Kuh	"],
				["	niedźwiedź	","	bear	","	Der Bär	"],
				["	jaszczurka	","	lizard	","	Die Eidechse	"],
				["	ryba	","	fish	","	Der Fisch	"],
				["	świnia	","	pig	","	Das Schwein	"],
				["	zwierzę	","	animal	","	das Tier	"],
				["	zwierzę domowe	","	pet	","	das Haustier	"],
				["	Kot leży pod stołem.	","	The cat is lying under the table.	","	Die Katze liegt unter dem Tisch.	"],
				["	Czy psy i koty to zwierzęta?	","	Are dogs and cats animals?	","	Sind Hunde und Katzen Tiere?	"],
				["	Ile ptaków jest w tym lesie?	","	How many birds are there in this forest?	","	Wie viele Vögel gibt es in diesem Wald?	"],
				["	Jaki słodki kotek!","	What a cute kitty!	","	Was für ein süßes Kätzchen!	"],
				["	Wyjdź z psem na spacer.	","	Take your dog for a walk.	","	Geh mit deinem Hund spazieren.	"],
				],
	"Vegetables" : [["	marchewka	","	carrot	","	Die Karotte	"],
				["	ziemniak	","	potato	","	Die Kartoffel	"],
				["	kalafior	","	cauliflower	","	Der Blumenkohl	"],
				["	brokuł	","	broccoli	","	Der Brokkoli	"],
				["	cebula	","	onion	","	Die Zwiebel	"],
				["	czosnek	","	garlic	","	Der Knoblauch	"],
				["	papryka	","	pepper	","	Die Paprika	"],
				["	fasola	","	beans	","	Die Bohnen	"],
				["	por	","	leek	","	Der Lauch	"],
				["	burak	","	beetroot	","	Die Rote Bete	"],
				["	warzywo	","	vegetable	","	Das Gemüse	"],
				["	Jakie jest twoje ulubione warzywo?	","	What's your favorite vegetable?	","	Was ist dein Lieblingsgemüse?	"],
				["	Ile kosztuje kilogram ziemniaków?	","	How much does a kilogram of potatoes cost?	","	Wie viel kostet ein Kilogramm Kartoffeln?	"],
				["	Musimy kupić więcej cebuli.	","	We need to buy more onions.	","	Wir müssen mehr Zwiebeln kaufen.	"],
				["	Trzy ziemniaki to zdecydowanie za mało	","	Three potatoes are definitely not enough.	","	Drei Kartoffeln reichen definitiv nicht.	"]],
	"Fruits" : [["	jabłko	","	the apple	","	Der Apfel	"],
				["	banan	","	the banana	","	Die Banane	"],
				["	ananas	","	the pineapple	","	Die Ananas	"],
				["	brzoskwinia	","	the peach	","	Der Pfirsich	"],
				["	cytryna	","	the lemon	","	Die Zitrone	"],
				["	pomarańcza	","	the orange	","	Die Orange	"],
				["	arbuz	","	the watermelon	","	Die Wassermelone	"],
				["	śliwka	","	the plum	","	Die Pflaume	"],
				["	wiśnia	","	the cherry	","	Die Kirsche	"],
				["	owoc	","	the fruit	","	Die Frucht	"],
				["	Czy banan to owoc?	","	Is banana a fruit?	","	Sind Bananen Früchte?	"],
				["	Ile jabłek można zjeść dziennie?	","	How many apples can you eat a day?	","	Wie viele Äpfel darf man am Tag essen?	"],
				["	Mam alergię na cytryny.	","	I have allergy on lemons.	","	Ich bin allergisch gegen Zitronen.	"],
				["	Jaki jest twój ulubiony owoc?	","	What is your favorite fruit?	","	Was ist deine Lieblingsfrucht?	"],
				],
	"Emotions" : [["smutny	","	sad	","	traurig	"],
				["	szczęśliwy	","	happy	","	glücklich	"],
				["	zły	","	angry	","	wütend	"],
				["	zawstydzony	","	ashamed	","	beschämt	"],
				["	znudzony	","	bored	","	gelangweilt	"],
				["	zakochany	","	in love	","	verliebt	"],
				["	zirytowany	","	annoyed	","	genervt	"],
				["	zajęty	","	busy	","	beschämt	"],
				["	leniwy	","	lazy	","	faul	"],
				["	przygnębiony	","	depressed	","	deprimiert	"],
				["	podekscytowany	","	excited	","	aufgeregt	"],
				["	Jak się czujesz?	","	How are you feeling?	","	Wie fühlst du dich?	"],
				["	Dlaczego jesteś smutny?	","	Why are you sad?	","	Warum bist du traurig?	"],
				["	Jestem zbyt leniwy.	","	I'm too lazy.	","	Ich bin zu faul.	"],
				]
				


}

var native_language = ""
var learning_language = ""
var starter_base = []
var categories_chosen = []
var step = 1



# Called when the node enters the scene tree for the first time.
func _ready():
	%Back.visible = false
	%All.visible = false
	%None.visible = false
	%Save.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_polish_native_pressed():
	native_language = "Polish"
	b = 0
	step_two()
	

func _on_english_native_pressed():
	native_language = "English"
	b = 1
	step_two()
	
func step_two():
	%Question.text = "What Language Do You Want To Learn?"
	step = 2
	var temp_array = lang_array.duplicate()
	temp_array.erase(native_language)
	var i = 0
	for butt in get_tree().get_nodes_in_group("LangButtons"):
		butt.text = temp_array[i]
		i+=1
	%NativeTongue.visible = false
	%LanguageContainer.visible = true
	%Back.visible = true
	

func _on_lang_button_pressed():
	choose_lang(0)
	step3()


func _on_lang_button_2_pressed():
	choose_lang(1)
	step3()


func _on_lang_button_3_pressed():
	choose_lang(2)
	step3()


func _on_lang_button_4_pressed():
	choose_lang(3)
	step3()


func _on_lang_button_5_pressed():
	choose_lang(4)
	step3()
	
func choose_lang(k):
	var temp_array = lang_array.duplicate()
	temp_array.erase(native_language)
	learning_language = temp_array[k]
	if learning_language == "Polish":
		a = 0
	elif  learning_language == "English":
		a = 1
	else:
		a = 2

func step3():
	%Question.text = "You can choose some starter words for your Base or start with an empty one:"
	step = 3
	var i = 0
	for butt in get_tree().get_nodes_in_group("StartersButtons"):
		butt.text = themes_array[i]
		if not word_categories.has(themes_array[i]):
			butt.tooltip_text = "not ready yet"
			butt.disabled = true
			i += 1
			continue
		butt.tooltip_text = ""
		for word in word_categories[themes_array[i]]:
			butt.tooltip_text += word[a] + " - " + word[b]  + "\n"
		i += 1
	%LanguageContainer.visible = false
	%StarterBase.visible = true
	%All.visible = true
	%None.visible = true
	%Save.visible = true




func _on_save_pressed():
	categories_chosen = []
	starter_base = []
	for butt in get_tree().get_nodes_in_group("StartersButtons"):
		if butt.button_pressed:
			categories_chosen.append(butt.text)
			for word in word_categories[butt.text]:
				starter_base.append({
					"date_added":Time.get_datetime_string_from_system(),
					"is_sentence":word[1].split(" ").size()>3,
					"original":word[a].strip_edges(),
					"translation":word[b].strip_edges(),
					"weight":0
					})
				if a == 2 and starter_base[-1]["original"].split(" ")[0].to_upper() in ["DIE", "DER", "DAS"] and not starter_base[-1]["is_sentence"]:
					var article = starter_base[-1]["original"].split(" ")[0].to_upper()
					var gender = "female" if article == "DIE" else ("neutral" if article == "DAS" else "male")
					starter_base[-1]["part_of_speech"] = "noun"
					starter_base[-1]["is_plural"] = false
					starter_base[-1]["gender"] = gender
				if a == 2 and b == 1 and starter_base[-1]["original"].split(" ")[0].to_upper() in ["DIE", "DER", "DAS"] and not starter_base[-1]["is_sentence"]:
					starter_base[-1]["translation"] = "the " + starter_base[-1]["translation"]
	print("YOU USE: ", native_language )
	print("LEARNING: ", learning_language)
	print("CHOSEN CATEGORIES: ", categories_chosen)
	for b in starter_base:
		print(b["original"])
	for b in starter_base:
		print(b)
	
	Base.BIG_ARRAY = starter_base
	Base.SMALL_ARRAY = starter_base
	get_tree().change_scene_to_file("res://german_menu.tscn")


func _on_back_pressed():
	if step == 3:
		step = 2
		%StarterBase.visible = false
		%LanguageContainer.visible = true
		%All.visible = false 
		%None.visible = false 
		%Save.visible = false
		categories_chosen = []
		starter_base = []
		learning_language = ""
		for butt in get_tree().get_nodes_in_group("StartersButtons"):
			butt.button_pressed = false
	elif step == 2:
		step = 1
		%NativeTongue.visible = true
		%LanguageContainer.visible = false
		native_language = ""
		%Back.visible = false
		


func _on_none_pressed():
	for butt in get_tree().get_nodes_in_group("StartersButtons"):
		butt.button_pressed = false


func _on_all_pressed():
	for butt in get_tree().get_nodes_in_group("StartersButtons"):
		butt.button_pressed = true
