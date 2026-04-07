extends Control
var mar_offset = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#start()
	if get_tree().current_scene == self:
		start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var max_length = 0
	for i in range(%SoupContainer.get_child_count()):
		var line = %SoupContainer.get_children()[i]
		if line == %SampleButton or line == %SampleContainer:
			continue
		max_length = max(max_length,line.size.x)	
		continue
		if i%2 == 0:
			pass
			#line.position.x += delta*100
			#line.get_node("MarginLeft").custom_minimum_size.x += delta*100
		else:
			#line.position.x -= delta*100
			if i == 3:
				print(line.position)
				if line.get_children()[0].size.x + line.get_children()[1].size.x < -line.position.x:
					line.position.x += line.get_children()[0].size.x + 10
					line.remove_child(line.get_children()[0])
					add_new_button(line)
	mar_offset += delta*10
	%MarginLeft.custom_minimum_size.x = max_length + mar_offset
	

func start():
	%SampleButton.visible = false
	%SampleContainer.visible = false
	for i in range(7):
		var new_line = %SampleContainer.duplicate()
		new_line.visible = true
		%SoupContainer.add_child(new_line)
		for j in range(5):
			var new_record = NewUtility.BIG_ARRAY.pick_random()
			while new_record["is_sentence"]:
				new_record = NewUtility.BIG_ARRAY.pick_random()
			var new_button = %SampleButton.duplicate()
			new_button.visible = true
			new_button.text = new_record["original"]
			new_button.button_down.connect(show_answer.bind(new_button,new_record))
			new_button.button_up.connect(hide_answer.bind(new_button,new_record))
			new_button.mouse_entered.connect(to_bigger.bind(new_button))
			new_button.mouse_exited.connect(to_normal.bind(new_button))
			new_line.add_child(new_button)
			new_button.get_node("AnimationPlayer").play("bigger")
			new_button.get_node("AnimationPlayer").stop()

func show_answer(butt:Button,record:Dictionary):
	butt.text = record["translation"]
	
func hide_answer(butt:Button,record:Dictionary):
	butt.text = record["original"]

func to_bigger(butt:Button):
	
	butt.get_node("AnimationPlayer").play("bigger")

	
func to_normal(butt:Button):
	if butt.get_node("AnimationPlayer").current_animation_position>0.05:
		butt.get_node("AnimationPlayer").play_backwards("bigger")
	else:
		butt.get_node("AnimationPlayer").play("RESET")
	#butt.get_node("AnimationPlayer").play("to_normal")
	
func add_new_button(line:HBoxContainer):
	var new_line = %SampleContainer.duplicate()
	var new_record = NewUtility.SMALL_ARRAY.pick_random()
	while new_record["is_sentence"]:
		new_record = NewUtility.SMALL_ARRAY.pick_random()
	var new_button = %SampleButton.duplicate()
	new_button.visible = true
	new_button.text = new_record["original"]
	new_button.button_down.connect(show_answer.bind(new_button,new_record))
	new_button.button_up.connect(hide_answer.bind(new_button,new_record))
	new_button.mouse_entered.connect(to_bigger.bind(new_button))
	new_button.mouse_exited.connect(to_normal.bind(new_button))
	line.add_child(new_button)
	new_button.get_node("AnimationPlayer").play("bigger")
	new_button.get_node("AnimationPlayer").stop()
