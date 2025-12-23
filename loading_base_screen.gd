extends Control
var bases_array : Array
var chosen = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%DeleteButton.disabled = true
	%LoadButton.disabled = true
	Base.load_array()
	var tab = []
	for i in range(30):
		var base_name = ["baza", "słówka", "vocabulary"].pick_random() + str(randi_range(2,59))
		var language = ["english", "german", "polish"].pick_random()
		var nat_lang = ["english", "german", "polish"].pick_random()
		var records_number = randi_range(0,40) #Pamiętać o pustej
		var base_base = []
		for ii in range(records_number):
			base_base.append(Base.BIG_ARRAY.pick_random())
		tab.append({"base_name" : base_name, "language":language,"nat_lang":nat_lang,"base_base":base_base})
	bases_array = tab
	for i in range (30):
		var new_butt :Button
		if i != 0:
			new_butt = %SampleBaseButton.duplicate()
			%BasesList.add_child(new_butt)
		else:
			new_butt = %SampleBaseButton
		new_butt.text = tab[i]["base_name"]
		new_butt.pressed.connect(_base_chosen.bind(i))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _base_chosen(i):
	%DeleteButton.disabled = false
	%LoadButton.disabled = false
	chosen = i
	%NameA.text = bases_array[i]["base_name"]
	%LangA.text = bases_array[i]["language"]
	%NumA.text = str(bases_array[i]["base_base"].size())
	for child in %SampleList.get_children():
		if child == %SampleRecord:
			continue
		child.queue_free()
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
		
			


func _on_delete_button_pressed() -> void:
	%BasesList.get_children()[chosen].queue_free()
	%NameA.text = ""
	%LangA.text = ""
	%NumA.text = ""
	for child in %SampleList.get_children():
		if child == %SampleRecord:
			continue
		child.queue_free()
		
	# NO I PAMIĘTAJ ŻEBY RZECZYWIŚCIE USUNĄĆ BAZĘ Z PAMIĘCI XD

	


func _on_load_button_pressed() -> void:
	var load_base = bases_array[chosen]
	Base.BIG_ARRAY = load_base["base_base"]
	Base.SMALL_ARRAY = Base.BIG_ARRAY
	Base.base_name = load_base["base_name"]
	Base.language = load_base["language"]
	Base.native_lang = load_base["nat_lang"]
	Base.is_genderless = Base.language == "english"
	Base.is_crossword_able = Base.language != "chinese"
	get_tree().change_scene_to_file("res://german_menu.tscn")


func _on_new_base_button_pressed() -> void:
	get_tree().change_scene_to_file("res://intro.tscn")
