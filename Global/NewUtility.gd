extends Node
var array_of_bases = []
var BIG_ARRAY = []
var SMALL_ARRAY = []
var z_to_y = false
var right_to_umlaut = true
var ae_to_umlaut = false
var spelling_copy = true
var spelling_translate = true
var spelling_fill = true
var gender_questions_amount = 10
var gender_keep_tested_words = false


const MAIN_FILE_PATH = "user://SQ_main.json"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#reset()
	load_main()
	load_settings()
	#load_old_base()
	

func load_main():
	if not FileAccess.file_exists(MAIN_FILE_PATH):
		print("First Run!")
		get_tree().change_scene_to_file("res://first_run_scene.tscn")
		reset()
		return
	
	var file = FileAccess.open(MAIN_FILE_PATH, FileAccess.READ)
	var json_string = file.get_as_text()  # Read the file content
	file.close()
	
	var json = JSON.parse_string(json_string)  # Convert JSON back to array
	if json == {}:
		reset()
		return
	array_of_bases = json["array_of_bases"]
	#print("json", json)
	if array_of_bases.size() == 0:
		reset()
	load_array()
	

func save_main():
	var file = FileAccess.open(MAIN_FILE_PATH, FileAccess.WRITE)
	var main_file = {
		"array_of_bases": array_of_bases
	}
	var json_string = JSON.stringify(main_file)  # Convert array to JSON
	file.store_string(json_string)  # Save to file
	file.close()
	

func reset():
	array_of_bases = []
	make_sample_bases()
	save_main()
	pass
	
func new_base(base_name:StringName, description:String):
	var new_key = gen_key()
	new_key = "user://" + new_key
	array_of_bases.insert(0,{"adress": new_key, "name":base_name,"description":description,"size":0,"samples":[],"created": Time.get_datetime_dict_from_system(), "edited": Time.get_datetime_dict_from_system(), "last_used": Time.get_datetime_dict_from_system() })
	
	var file1 = FileAccess.open(new_key+"_base", FileAccess.WRITE)
	var json_string = JSON.stringify([])
	file1.store_string(json_string)
	file1.close()
	
	var file2 = FileAccess.open(new_key+"_settings",FileAccess.WRITE)
	var settings = {
		"z_to_y": z_to_y,
		"right_to_umlaut": right_to_umlaut,
		"ae_to_umlaut": ae_to_umlaut,
		"spelling_copy": spelling_copy,
		"spelling_fill": spelling_fill,
		"spelling_translate": spelling_translate,
		"gender_questions_amount": gender_questions_amount,
		"gender_keep_tested_words": gender_keep_tested_words
	}
	json_string = JSON.stringify(settings)
	file2.store_string(json_string)
	file2.close()
	
	var file3 = FileAccess.open(new_key+"_ignore_words",FileAccess.WRITE)
	var ignore_words = []
	json_string = JSON.stringify(ignore_words)
	file3.store_string(json_string)
	file3.close()
	
func gen_key():
	randomize()
	var result = str(randi_range(10000,99999))
	for a in array_of_bases:
		if a["adress"] == result:
			result = gen_key()
	return result
	
func load_array():
	var file = FileAccess.open(array_of_bases[0]["adress"] + "_base",FileAccess.READ)
	var loaded_base = JSON.parse_string(file.get_as_text())
	BIG_ARRAY = loaded_base
	SMALL_ARRAY = loaded_base
	file.close()
	if array_of_bases[0].has("last_used"):
		pass

func update_last_used():
	array_of_bases[0]["last_used"] = Time.get_datetime_dict_from_system()
	save_main()
	
func save_array():
	if get_tree().has_group("ProgressBar"):
		if get_tree().get_nodes_in_group("ProgressBar").size()>0:
			get_tree().get_first_node_in_group("ProgressBar").update()
	var adress = array_of_bases[0]["adress"]
	var file = FileAccess.open(adress + "_base",FileAccess.WRITE)
	var json_file = JSON.stringify(BIG_ARRAY)
	file.store_string(json_file)
	file.close()
	if BIG_ARRAY.size() > 0:
		array_of_bases[0]["size"] = BIG_ARRAY.size()
		BIG_ARRAY.shuffle()
		array_of_bases[0]["samples"] = []
		for i in range(min(20,BIG_ARRAY.size())):
			array_of_bases[0]["samples"].append(BIG_ARRAY[i]["original"] + " - " + BIG_ARRAY[i]["translation"])
		save_main()

func load_ignore_words():
	var adress= array_of_bases[0]["adress"] + "_ignore_words"
	var file = FileAccess.open(adress,FileAccess.READ)
	var result = JSON.parse_string(file.get_as_text())
	file.close()
	return result
	
func save_ignore_words(words_array:Array):
	var adress= array_of_bases[0]["adress"] + "_ignore_words"
	var file = FileAccess.open(adress,FileAccess.WRITE)
	file.store_string(JSON.stringify(words_array))

func load_settings():
	var file = FileAccess.open(array_of_bases[0]["adress"] + "_settings",FileAccess.READ)
	var loaded_settings = JSON.parse_string(file.get_as_text())
	if loaded_settings.has("z_to_y"):
		z_to_y = loaded_settings["z_to_y"]
	if loaded_settings.has("right_to_umlaut"):
		right_to_umlaut = loaded_settings["right_to_umlaut"]
	if loaded_settings.has("ae_to_umlaut"):
		ae_to_umlaut = loaded_settings["ae_to_umlaut"]
	if loaded_settings.has("spelling_copy"):
		spelling_copy = loaded_settings["spelling_copy"]
	if loaded_settings.has("spelling_fill"):
		spelling_fill = loaded_settings["spelling_fill"]
	if loaded_settings.has("spelling_translate"):
		spelling_translate = loaded_settings["spelling_translate"]
	if loaded_settings.has("gender_questions_amount"):
		gender_questions_amount = loaded_settings["gender_questions_amount"]
	if loaded_settings.has("gender_keep_tested_words"):
		gender_keep_tested_words = loaded_settings["gender_keep_tested_words"]
	file.close()

func save_settings():
	var file = FileAccess.open(array_of_bases[0]["adress"]+"_settings",FileAccess.WRITE)
	var settings = {
		"z_to_y": z_to_y,
		"right_to_umlaut": right_to_umlaut,
		"ae_to_umlaut": ae_to_umlaut,
		"spelling_copy": spelling_copy,
		"spelling_fill": spelling_fill,
		"spelling_translate": spelling_translate,
		"gender_questions_amount": gender_questions_amount,
		"gender_keep_tested_words": gender_keep_tested_words
	}
	var json_string = JSON.stringify(settings)
	file.store_string(json_string)
	file.close()

func test():
	var a1 = [{"a":"A","b":3},{"a":"AA","b":4}]
	var a2 = []
	a2.append(a1[0])
	#print(a1,a2)
	a2[0]["a"] = "C"
	a2[0]["b"] = 5
	#print(a1,a2)
	
func move_base_to_front(base_index):
	array_of_bases.push_front(array_of_bases.pop_at(base_index))
	
func make_sample_bases():
	SampleBases.All.reverse()
	for base in SampleBases.All:	
		var new_array = base["array"]
		new_base(base["name"], base["description"])
		load_array()
		for word in new_array:
			
			var new_record = {"original":word["german"], "translation":word["english"],  "weight": 0, "date_added": Time.get_datetime_string_from_system()}
			
			
			if new_record["original"].split(" ").size()>3:
				new_record["is_sentence"] = true
				BIG_ARRAY.append(new_record)
				continue
			new_record["is_sentence"] = false
			if new_record["original"].split(" ")[0] == "die" or array_of_bases[0]["name"] == "Daily Sentences":
				new_record["part_of_speech"] = "noun"
				new_record["gender"] = "female"
				new_record["is_plural"] = false
			elif new_record["original"].split(" ")[0] == "der":
				new_record["part_of_speech"] = "noun"
				new_record["gender"] = "male"
				new_record["is_plural"] = false
			elif new_record["original"].split(" ")[0] == "das":
				new_record["part_of_speech"] = "noun"
				new_record["gender"] = "neutral"
				new_record["is_plural"] = false
			BIG_ARRAY.append(new_record)
			
		save_array()

func load_old_base():
	if not FileAccess.file_exists("user://FiszkiGerman.json"):
		print("File not found!")
		return []
	
	var file = FileAccess.open("user://FiszkiGerman.json", FileAccess.READ)
	var json_string = file.get_as_text()  # Read the file content
	file.close()
	
	var json = JSON.parse_string(json_string)  # Convert JSON back to array
	BIG_ARRAY = json
	save_array()
	pass
