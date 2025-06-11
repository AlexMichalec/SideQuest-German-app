extends Node2D
var BIG_ARRAY

# Called when the node enters the scene tree for the first time.
func _ready():
	save_originals()
	save_translations()
	pass
	
func save_originals():
	var desktop_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
	var file_path = desktop_path + "/myGermanInput.txt"
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	BIG_ARRAY = Utility.load_array()
	for b in BIG_ARRAY:
		file.store_string(b["original"] + "\n")
	file.close()

func save_translations():
	var desktop_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
	var file_path = desktop_path + "/myTranslationInput.txt"
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	BIG_ARRAY = Utility.load_array()
	for b in BIG_ARRAY:
		file.store_string(b["translation"] + "\n")
	file.close()
		

func save_to_desktop(text):
	var desktop_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
	var file_path = desktop_path + "/myFile.txt"
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string("Hello from Godot!")
		file.close()
		print("File saved to desktop:", file_path)
	else:
		print("Failed to open file.")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
