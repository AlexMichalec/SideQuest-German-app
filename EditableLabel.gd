extends Label
signal text_edited(old_text:String, new_text:String)
@export var editable = true
var mouse_in = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not editable:
		$Button.visible = false
	pass


func _on_button_pressed():
	$LineEdit.visible = true
	$LineEdit.text = text
	label_settings.font_color = Color.TRANSPARENT
	$Button.visible = false

func _on_line_edit_text_submitted(new_text):
	text_edited.emit(text, $LineEdit.text)
	text = new_text
	label_settings.font_color = Color.WHITE
	$LineEdit.visible = false
	$Button.visible = true


func _on_mouse_entered():
	mouse_in = true
	if not editable:
		return
	if $LineEdit.visible:
		return
	$Button.visible = true


func _on_mouse_exited():
	mouse_in = false
	if $LineEdit.visible:
		return
	await get_tree().create_timer(0.5).timeout
	if not mouse_in:
		$Button.visible = false



func _on_button_mouse_entered():
	mouse_in = true


func _on_button_mouse_exited():
	mouse_in = false
	if $LineEdit.visible:
		return
	await get_tree().create_timer(0.5).timeout
	if not mouse_in:
		$Button.visible = false
