extends Node



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
