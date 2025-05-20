extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		child.tint = [Color.RED, Color.ORANGE, Color.YELLOW, Color.GREEN, Color.BLUE, Color.AQUA, Color.BLUE_VIOLET].pick_random()
		child.recolor()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
