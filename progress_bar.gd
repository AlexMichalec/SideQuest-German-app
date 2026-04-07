extends TextureProgressBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#update()
	pass


func _on_main_menu_draw() -> void:
	return
	update()

func update_start():
	if NewUtility.BIG_ARRAY.size() == 0:
		value = 0
		$Label.text = "0.0%"
		return
	update_fast()
	#await  get_tree().create_timer(1).timeout
	lower_weights()
	"""
	var new_tween = get_tree().create_tween()
	new_tween.tween_property(self,"scale",Vector2(1.2,1.2),0.5)
	new_tween.tween_property(self,"scale",Vector2(1.2,1.2),2.0)
	new_tween.tween_property(self,"scale",Vector2(1.0,1.0),0.5)
	await get_tree().create_timer(0.2).timeout
	"""
	update()
	NewUtility.update_last_used()
	NewUtility.save_main()

func lower_weights():
	var days = get_days()
	var ratio = pow(0.9,days)
	ratio = round(ratio*10)/10
	print("ratio ", ratio)
	for record in NewUtility.BIG_ARRAY:
		record["weight"] *= ratio
		record["weight"] = round(record["weight"]*10)/10.0
	

func get_days():
	if not NewUtility.array_of_bases[0].has("last_used"):
		NewUtility.array_of_bases[0]["last_used"] = Time.get_datetime_dict_from_system()
		NewUtility.save_main()
		return 0
	var now = Time.get_datetime_dict_from_system()
	var last_used = NewUtility.array_of_bases[0]["last_used"]
	var month_dict = {1:31,2:28,3:31,4:30,5:31,6:30,7:31,8:31,9:30,10:31,11:30,12:31}
	
	var result = 0
	if now ["month"] > last_used["month"]+1 or (now["month"] == last_used["month"] and now["day"] - last_used["day"]>=20) or (now["year"] - last_used["year"]>=1 and now["month"]!=1):
		return 20
	if now["month"] == last_used["month"]:
		return min(20,now["day"] - last_used["day"])
	if now["month"]-1 == last_used["month"] or (now["month"] == 1 and last_used["month"] == 12):
		return min(20,now["day"] + month_dict[int(last_used["month"])])
	
func update_fast():
	var progress_sum = 0
	for record in NewUtility.BIG_ARRAY:
		progress_sum += record["weight"]

	var result = 10.0 * float(progress_sum) / float(NewUtility.BIG_ARRAY.size())
	value = result
	$Label.text = str(round(result*10)/10) + "%"

func update():
	if NewUtility.BIG_ARRAY.size() == 0:
		value = 0
		$Label.text = "0.0%"
		return

	var progress_sum = 0.0
	for record in NewUtility.BIG_ARRAY:
		progress_sum += record["weight"]

	var result = 10.0 * float(progress_sum) / float(NewUtility.BIG_ARRAY.size())
	#value = result
	var temp = abs(round((result - value)*5))
	var t_step = 0.2
	var old_value = value
	
		
	if abs(result - value)>2:
		var tween1 = get_tree().create_tween()
		tween1.tween_property(self,"value",result,2)
	else:
		value = result
	if temp >5:	
		if temp > 15:
			temp = result - value
			t_step = ceil(temp/2)/10
			temp = floor(temp/t_step)
		for i in range(temp):
			old_value += t_step
			$Label.text = str(round(old_value*10)/10) + "%"
			await get_tree().create_timer(0.1).timeout
	$Label.text = str(round(result*10)/10) + "%"
