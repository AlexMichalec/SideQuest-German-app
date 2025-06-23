extends Panel

var date_list : Array
var categories_list : Array
var other_list:Array
var long_word_length = 12
var max_word_length = 15
var vis1 = false

signal edited

# Called when the node enters the scene tree for the first time.
func _ready():
	date_list =  []
	categories_list = []
	other_list = []
	for b in Base.BIG_ARRAY:
		date_list.append(b)
		categories_list.append(b)
		other_list.append(b)
	print(Time.get_datetime_string_from_system())
	prepare_date_buttons()
	_on_all_date_button_pressed()
	set_long_word_length()
	pass # Replace with function body.
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func prepare_date_buttons():
	var dates_array = Filter.by_date(0, "","", true)
	for i in range(dates_array.size()):
		var date = dates_array[i]
		var new_button = %DateButtonSample.duplicate()
		new_button.visible = true
		new_button.text = date[0] + ": (" + str(date.size()-1)+ ") "
		new_button.connect("toggled", func(button_pressed):date_button_clicked(button_pressed,i))
		for ii in range(min(3,date.size()-1)):
			new_button.text = new_button.text + date[ii+1]["original"] + ", "
		if new_button.text.length() > 50:
			new_button.text = new_button.text.left(50) + "..."
		%DateButtonContainer.add_child(new_button)

func update_array_label():
	update_small_array()
	Base.SMALL_ARRAY.shuffle()
	%BIG_ARRAY_LABEL.text = "Total: " + str(Base.SMALL_ARRAY.size()) + "\n"
	for b in Base.SMALL_ARRAY:
		%BIG_ARRAY_LABEL.text += b["original"] + ", "
		if %BIG_ARRAY_LABEL.text.length() > 1000:
			%BIG_ARRAY_LABEL.text = %BIG_ARRAY_LABEL.text + "\n[...]"
			return

func update_small_array():
	var BIG = Base.load_array()
	var temp = []
	for b in BIG:
		if not b in date_list:
			continue
		if not b in categories_list:
			continue
		if not b in other_list:
			continue
		temp.append(b)
	Base.SMALL_ARRAY = temp

func _on_date_button_sample_pressed():
	%AllDateButton.button_pressed = false
	%NoneDateButton.button_pressed = false
	check_if_all_pressed_date()
	check_if_none_pressed_date()
	edited.emit()

func check_if_all_pressed_date():
	for butt in %DateButtonContainer.get_children():
		if butt == %DateButtonSample:
			continue
		if not butt.button_pressed:
			return false
	%AllDateButton.button_pressed = true
	return true

func check_if_none_pressed_date():
	for butt in %DateButtonContainer.get_children():
		if butt == %DateButtonSample:
			continue
		if butt.button_pressed:
			return false
	%NoneDateButton.button_pressed = true
	return true


func _on_all_date_button_pressed():
	%NoneDateButton.button_pressed = false
	for butt in %DateButtonContainer.get_children():
		if butt == %DateButtonSample:
			continue
		butt.button_pressed = true
	date_list= Base.BIG_ARRAY
	update_array_label()
	edited.emit()


func _on_none_date_button_pressed():
	%AllDateButton.button_pressed = false
	for butt in %DateButtonContainer.get_children():
		if butt == %DateButtonSample:
			continue
		butt.button_pressed = false
	date_list = []
	update_array_label()
	edited.emit()

func date_button_clicked(button_pressed:bool, date_index:int):
	if button_pressed:
		add_day(date_index)
	else:
		erase_day(date_index)
	edited.emit()
		
func add_day(date_index :int):
	var temp = Filter.by_date(date_index)
	for t in temp:
		if t in date_list:
			continue
		else:
			date_list.append(t)
	update_array_label()
	print("ADD ", Base.BIG_ARRAY.size())

func erase_day(date_index:int):
	for f in Filter.by_date(date_index):
		date_list.erase(f)
	update_array_label()
	print("ERASE ", Base.BIG_ARRAY.size())



func _on_today_button_pressed():
	for butt in %DateButtonContainer.get_children():
		if butt == %DateButtonSample:
			continue
		butt.button_pressed = false
	%DateButtonContainer.get_children()[1].button_pressed = true
	update_array_label()
	edited.emit()


func _on_week_button_pressed():
	var week_ago = Time.get_datetime_dict_from_system()
	if week_ago["day"] >= 8:
		week_ago["day"] -= 7
	elif week_ago["month"] not in [1,3]:
		week_ago["month"] -= 1
		week_ago["day"] += (31 if week_ago["month"] in [1,3,5,7,8,10,12] else 30) - 7
	elif week_ago["month"] == 3:
		week_ago["month"] -= 1
		week_ago["day"] += (28 if week_ago["year"] % 4 !=0 else 29) - 7
	else:
		week_ago["year"] -= 1
		week_ago["month"] = 12
		week_ago["day"] += 31 - 7
	var week_ago_str = Time.get_datetime_string_from_datetime_dict(week_ago,false)
	print("week ago... ", week_ago_str)
	for butt in %DateButtonContainer.get_children():
		if butt.text.left(10)>=week_ago_str.left(10):
			butt.button_pressed = true
		else:
			butt.button_pressed = false
	edited.emit()


func _on_month_button_pressed():
	var month_ago = Time.get_datetime_dict_from_system()
	if month_ago["month"] > 1:
		month_ago["month"] = month_ago["month"] - 1
	else:
		month_ago["year"] -= 1
		month_ago["month"] = 12
	if month_ago["month"] in [4,6,9,11]:
		month_ago["day"] = min (30, month_ago["day"])
	if month_ago["month"] == 2:
		month_ago["day"] = min (29 if month_ago["year"]%4 == 0 else 28, month_ago["day"])
	var month_ago_str = Time.get_datetime_string_from_datetime_dict(month_ago,false)
	print("month ago... ", month_ago_str)
	for butt in %DateButtonContainer.get_children():
		if butt.text.left(10)>=month_ago_str.left(10):
			butt.button_pressed = true
		else:
			butt.button_pressed = false
	edited.emit()


func _on_close_button_pressed():
	%OpenButton.visible = true
	%MainContainer.visible = false


func _on_open_button_pressed():
	%OpenButton.visible = false
	%MainContainer.visible = true


func _on_only_words_toggled(button_pressed):
	if button_pressed:
		var temp = []
		for b in Base.BIG_ARRAY:
			if not b["is_sentence"]:
				temp.append(b)
		other_list = temp
		update_array_label()
	else:
		print("OUT")
		other_list = Base.BIG_ARRAY
		update_array_label()
	edited.emit()



func _on_only_sentences_toggled(button_pressed):
	if button_pressed:
		var temp = []
		for b in Base.BIG_ARRAY:
			if b["is_sentence"]:
				temp.append(b)
		other_list = temp
		update_array_label()
	else:
		other_list = Base.BIG_ARRAY
		update_array_label()
	edited.emit()

	



func _on_date_button_pressed():
	%DatesContainer.visible = true
	%CategoriesContainer.visible = false 
	%OtherContainer.visible = false


func _on_categories_button_pressed():
	%DatesContainer.visible = false
	%CategoriesContainer.visible = true
	%OtherContainer.visible = false

func _on_other_button_pressed():
	%DatesContainer.visible = false
	%CategoriesContainer.visible = false 
	%OtherContainer.visible = true


func _on_only_nouns_toggled(button_pressed):
	if button_pressed:
		var temp = []
		for b in Base.BIG_ARRAY:
			if not b.has("part_of_speech"):
				continue
			if b["part_of_speech"] == "noun":
				temp.append(b)
		other_list = temp
		update_array_label()
	else:
		other_list = Base.BIG_ARRAY
		update_array_label()
	edited.emit()


func _on_only_adjectives_toggled(button_pressed):
	if button_pressed:
		var temp = []
		for b in Base.BIG_ARRAY:
			if not b.has("part_of_speech"):
				continue
			if b["part_of_speech"] == "adjective":
				temp.append(b)
		other_list = temp
		update_array_label()
	else:
		other_list = Base.BIG_ARRAY
		update_array_label()
	edited.emit()


func _on_only_verbs_toggled(button_pressed):
	if button_pressed:
		var temp = []
		for b in Base.BIG_ARRAY:
			if not b.has("part_of_speech"):
				continue
			if b["part_of_speech"] == "verb":
				temp.append(b)
		other_list = temp
		update_array_label()
	else:
		other_list = Base.BIG_ARRAY
		update_array_label()
	edited.emit()


func _on_only_long_words_toggled(button_pressed):
	if button_pressed:
		var temp = []
		for b in Base.BIG_ARRAY:
			if b["is_sentence"]:
				continue
			if " " in b["original"]:
				if b["original"].left(3).to_lower() in ["die", "der", "das"]:
					if b["original"].length() - 4 >= long_word_length:
						temp.append(b)
				continue
			if b["original"].length() >= long_word_length:
				temp.append(b)
		other_list = temp
		update_array_label()
	else:
		other_list = Base.BIG_ARRAY
		update_array_label()
	edited.emit()

func set_long_word_length():
	var max_tab = []
	for b in Base.BIG_ARRAY:
		if " " in b["original"]:
			if b["original"].left(3).to_lower() in ["die", "der", "das"] and not b["is_sentence"]:
				max_tab.append(b["original"].length()-4)
			continue
		max_tab.append(b["original"].length())
	max_tab.sort()
	max_tab.reverse()
	var prog = int(max_tab.size()/10)
	long_word_length = max_tab[prog]
	max_word_length = max_tab[0]
	print(long_word_length)



func _on_less_pressed():
	long_word_length -= 1
	%LWLabel.text = str(long_word_length)
	if long_word_length == 1:
		%Less.disabled = true
	if long_word_length == max_word_length -1:
		%More.disabled = false
	if %OnlyLongWords.button_pressed:
		_on_only_long_words_toggled(true)

func _on_more_pressed():
	long_word_length += 1
	%LWLabel.text = str(long_word_length)
	if long_word_length == 2:
		%Less.disabled = false
	if long_word_length == max_word_length:
		%More.disabled = true
	if %OnlyLongWords.button_pressed:
		_on_only_long_words_toggled(true)
