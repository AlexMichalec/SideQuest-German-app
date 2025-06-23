extends Node

var BIG_ARRAY = []
var SMALL_ARRAY = [] #Po Filtrowaniu

func _ready():
	BIG_ARRAY = load_array()
	SMALL_ARRAY = load_array()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func reload():
	BIG_ARRAY = load_array()
	SMALL_ARRAY = load_array()
	
func save():
	save_array(BIG_ARRAY)
	

func load_array():
	if not FileAccess.file_exists("user://FiszkiGerman.json"):
		print("File not found!")
		return []
	
	var file = FileAccess.open("user://FiszkiGerman.json", FileAccess.READ)
	var json_string = file.get_as_text()  # Read the file content
	file.close()
	
	var json = JSON.parse_string(json_string)  # Convert JSON back to array
	return json if json is Array else []

func save_array(BIG_SET):
	var file = FileAccess.open("user://FiszkiGerman.json", FileAccess.WRITE)
	var json_string = JSON.stringify(BIG_SET)  # Convert array to JSON
	file.store_string(json_string)  # Save to file
	file.close()
	
func load_safe_array():
	if not FileAccess.file_exists("user://FiszkiGermanSafe.json"):
		print("File not found!")
		return []
	
	var file = FileAccess.open("user://FiszkiGermanSafe.json", FileAccess.READ)
	var json_string = file.get_as_text()  # Read the file content
	file.close()
	
	var json = JSON.parse_string(json_string)  # Convert JSON back to array
	return json if json is Array else []
	
func save_safe_array():
	var file = FileAccess.open("user://FiszkiGermanSafe.json", FileAccess.WRITE) #"user://FiszkiGermanSafe.json",
	var json_string = JSON.stringify(BIG_ARRAY)  # Convert array to JSON
	file.store_string(json_string)  # Save to file
	file.close()

func unite_bases():
	var array1 = load_array()
	var array2 = load_safe_array()
	var result = array1
	for a in array2:
		if not a in result:
			result.append(a)
	print(array1.size(), " ", array2.size(), " ", result.size())
	save_array(result)
