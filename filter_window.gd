extends Panel
var BIG_ARRAY = []

# Called when the node enters the scene tree for the first time.
func _ready():
	print(Time.get_datetime_string_from_system())
	prepare_date_buttons()
	_on_all_date_button_pressed()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func prepare_date_buttons():
	var dates_array = Filter.by_date(Utility.load_array(), 0, "","", true)
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
	BIG_ARRAY.shuffle()
	%BIG_ARRAY_LABEL.text = "Total: " + str(BIG_ARRAY.size()) + "\n"
	for b in BIG_ARRAY:
		%BIG_ARRAY_LABEL.text += b["original"] + ", "
		if %BIG_ARRAY_LABEL.text.length() > 1000:
			%BIG_ARRAY_LABEL.text = %BIG_ARRAY_LABEL.text + "\n[...]"
			return

func _on_date_button_sample_pressed():
	%AllDateButton.button_pressed = false
	%NoneDateButton.button_pressed = false
	check_if_all_pressed_date()
	check_if_none_pressed_date()

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
	BIG_ARRAY = Utility.load_array()
	update_array_label()


func _on_none_date_button_pressed():
	%AllDateButton.button_pressed = false
	for butt in %DateButtonContainer.get_children():
		if butt == %DateButtonSample:
			continue
		butt.button_pressed = false
	BIG_ARRAY = []
	update_array_label()

func date_button_clicked(button_pressed:bool, date_index:int):
	if button_pressed:
		add_day(date_index)
	else:
		erase_day(date_index)
		
func add_day(date_index :int):
	BIG_ARRAY.append_array(Filter.by_date(Utility.load_array(),date_index))
	update_array_label()

func erase_day(date_index:int):
	for f in Filter.by_date(Utility.load_array(),date_index):
		BIG_ARRAY.erase(f)
	update_array_label()



func _on_today_button_pressed():
	for butt in %DateButtonContainer.get_children():
		if butt == %DateButtonSample:
			continue
		butt.button_pressed = false
	%DateButtonContainer.get_children()[1].button_pressed = true
	update_array_label()


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


func _on_close_button_pressed():
	%OpenButton.visible = true
	%MainContainer.visible = false


func _on_open_button_pressed():
	%OpenButton.visible = false
	%MainContainer.visible = true
