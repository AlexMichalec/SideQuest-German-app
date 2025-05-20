extends VBoxContainer
var minutes = 25
var seconds = 0
var total_time = 0
var is_break = false
var second_counter = 0
var is_on = false
var is_paused = false
var standard_learning_minutes = 25
var standard_break_minutes = 5
var repetitions = 4
var goal_time = repetitions * standard_learning_minutes + (repetitions - 1) * standard_break_minutes

# Called when the node enters the scene tree for the first time.
func _ready():
	%PomProgressBar.value = 0
	%PomTime.text = "25:00"
	%PauseButton.text = "Start"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_on or is_paused:
		return
	second_counter += delta
	if second_counter>0.1:
		total_time += 1
		second_counter -= 0.1
		seconds -= 1
		if seconds < 0:
			minutes -= 1
			if minutes == -1:
				if total_time >= goal_time*60:
					is_on = false
					%PomTime.text = "0:00"
					return
				is_break = not is_break
				minutes = standard_break_minutes if is_break else standard_learning_minutes
				seconds = 0
			else:
				seconds = 59
		%PomProgressBar.value = total_time/60
		%PomTime.text = str(minutes) + ":" + (str(seconds) if seconds>9 else ("0" + str(seconds)))
			


func _on_pause_button_pressed():
	if not is_on:
		is_on = true
		%PauseButton.text = "Pause"
		goal_time = repetitions * standard_learning_minutes + (repetitions - 1) * standard_break_minutes
		%PomProgressBar.max_value = goal_time
	else:
		if is_paused:
			%PauseButton.text = "Pause"
			is_paused = false
		else:
			%PauseButton.text = "Resume"
			is_paused = true
		


func _on_stop_button_pressed():
	is_on = false
	is_paused = false
	is_break = false
	total_time = 0
	minutes = standard_learning_minutes
	seconds = 0
	%PauseButton.text = "Start"
	%PomProgressBar.value = 0
	%PomTime.text = str(standard_learning_minutes) + ":00"
	
