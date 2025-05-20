extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_show_day_pressed():
	%ShowWeek.button_pressed = false
	%ShowMonth.button_pressed = false
	%ShowAll.button_pressed= false

func _on_show_week_pressed():
	%ShowDay.button_pressed = false
	%ShowMonth.button_pressed = false
	%ShowAll.button_pressed= false


func _on_show_month_pressed():
	%ShowDay.button_pressed = false
	%ShowWeek.button_pressed = false
	%ShowAll.button_pressed= false


func _on_show_all_pressed():
	%ShowDay.button_pressed = false
	%ShowWeek.button_pressed = false
	%ShowMonth.button_pressed = false

