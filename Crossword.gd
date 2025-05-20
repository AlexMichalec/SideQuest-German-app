extends VBoxContainer
var BIG_ARRAY : Array
var given_words :Array
var buttons_array
var tip_text = ""
var info_points_global = []
var chosen_one_timer = 0 
var score = 0
var crossword_checked = false
var solution_points = 0
signal closed
# Called when the node enters the scene tree for the first time.
func _ready():
	prepare_buttons()
	#check_words_amount()
	if get_tree().current_scene == self:
		start()
	
func start():
	score = 0
	%Score.text = "0p"
	%NewPoints.text = ""
	BIG_ARRAY = load_array()
	var words_for_crossword = choose_new_words()
	make_best_crossword(words_for_crossword)
	#glue_two_words(words_for_crossword[0][0],words_for_crossword[1][0])
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible:
		nav_info_points()
	chosen_one_timer = max(0, chosen_one_timer-delta)


func nav_info_points():
	for i in range(10):
		if Input.is_action_just_pressed(str(i)):
			var if_horizontal = true
			if chosen_one_timer == 0 and i == 0:
				return
			var x = info_points_global[i-1][0]
			var y = info_points_global[i-1][1]
			if_horizontal = info_points_global[i-1][2]
				
			if chosen_one_timer>0 and 10+i-1< info_points_global.size():
				x = info_points_global[10+i-1][0]
				y = info_points_global[10+i-1][1]
				if_horizontal = info_points_global[10+i-1][2]
				chosen_one_timer = 0.3
			if i==1 and chosen_one_timer == 0:
				chosen_one_timer = 0.3
				await get_tree().create_timer(0.3).timeout
				if chosen_one_timer == 0:
					buttons_array[x][y].get_node("Input").grab_focus()
					
			else:
				buttons_array[x][y].get_node("Input").grab_focus()
				if if_horizontal:
					buttons_array[x][y].force_right = true
					buttons_array[x][y].force_down = false
				else:
					buttons_array[x][y].force_down = true
					buttons_array[x][y].force_right = false
			
			
		
		
	
func check_words_amount():
	var counter1 = 0
	var counter2 = 0
	var size_array = []
	for i in range(100):
		size_array.append(0)
	for record in BIG_ARRAY:
		if record[0].split(" ").size()==1:
			counter1 += 1
		elif record[0].split(" ").size() == 2 and record[0].split(" ")[0].to_upper() in ["DIE", "DAS", "DER"]:
			counter2 += 1
		size_array[min(100,record[0].length())] += 1
	
func hiding_cells():
	for line in buttons_array:
		for butt in line:
			butt.visible = true
	for i in range(buttons_array.size()):
		var to_hid = true
		for butt in buttons_array[i]:
			if butt.square_type == "white":
				to_hid = false
		if not to_hid:
			continue
		for butt in buttons_array[i]:
			butt.visible = false
	for j in range(buttons_array[0].size()):
		var to_hid = true
		for i in range(buttons_array.size()):
			if buttons_array[i][j].square_type == "white":
				to_hid = false
		if not to_hid:
			continue
		for i in range(buttons_array.size()):
			buttons_array[i][j].visible = false
		
func update_solution():
	%SolutionContainer.visible = true
	var break_counter= 0
	var previous_button = null
	for child in %SolutionContainer.get_children():
		if child != %HasloLabel and child != %HasloCrossSample and child != %HasloEmpty:
			child.queue_free()
	var new_solution = BIG_ARRAY.pick_random()
	while new_solution[0].length()>20 or new_solution[0].to_upper() in given_words or not can_be_solution(new_solution[0]):
		new_solution = BIG_ARRAY.pick_random()
		break_counter += 1
		if break_counter > 100:
			%SolutionContainer.visible = false
			return
	%HasloLabel.text = new_solution[1] + " = "
	var counter_sol_numbers = 1
	for n in new_solution[0].to_upper():
		if n == " ":
			var new_break = %HasloEmpty.duplicate()
			new_break.visible = true
			%SolutionContainer.add_child(new_break)
		else:
			var possible_places = []
			for line in buttons_array:
				for butt in line:
					if butt.square_type != "white":
						continue
					if butt.correct_letter == n and butt.do_hasla == false:
						possible_places.append(butt)
			possible_places.shuffle()
			var new_letter = %HasloCrossSample.duplicate()
			new_letter.visible = true
			new_letter.set_text(n)
			#new_letter.get_node("Input").text = n
			%SolutionContainer.add_child(new_letter)
			if possible_places.size() >0:
				new_letter.set_important(possible_places[0], counter_sol_numbers)
				possible_places[0].set_important(new_letter, counter_sol_numbers)
				counter_sol_numbers += 1
			else:
				new_letter.get_node("ColorRect").color = Color.RED
			if previous_button != null:
				previous_button.to_right = new_letter
			previous_button = new_letter
		

func can_be_solution(word:String):
	for letter in word.to_upper():
		var how_many_letters_in_word = 0
		for l in word.to_upper():
			if l == letter:
				how_many_letters_in_word += 1
		var how_many_letters_in_crossword = 0
		for line in buttons_array:
			for button in line:
				if button.square_type != "white":
					continue
				if button.correct_letter == letter:
					how_many_letters_in_crossword += 1
		if how_many_letters_in_crossword < how_many_letters_in_word:
			return false
	return true

func prepare_buttons():
	var new_array = []
	for line in %CrossWord.get_children():
		var new_line = []
		for button in line.get_children():
			new_line.append(button)
		new_array.append(new_line)
	buttons_array = new_array

func show_crossword(crossword, info_points:Array):
	for i in range(crossword.size()):
		for j in range(crossword[i].size()):
			if crossword[i][j] == " ":
				buttons_array[i][j].set_empty()
			else:
				buttons_array[i][j].set_text(crossword[i][j])
	var counter = 1
	info_points.sort_custom(info_points_sort)
	for i in range(%HorLegend.get_child_count()):
		if i > 1:
			%HorLegend.get_children()[i].queue_free()
	for i in range(%VerLegend.get_child_count()):
		if i > 1:
			%VerLegend.get_children()[i].queue_free()
	for point in info_points:
		buttons_array[point[0]][point[1]].set_info("text",counter,point[2])
		if point[2]:
			var new_label = %HorizontalSample.duplicate()
			new_label.visible = true
			new_label.text = str(counter) + ". " + point[4].capitalize()
			%HorLegend.add_child(new_label)
		else:
			var new_label = %VerticalSample.duplicate()
			new_label.visible = true
			new_label.text = str(counter) + ". " + point[4].capitalize()
			%VerLegend.add_child(new_label)
		counter += 1
	manage_focuses(info_points)

func manage_focuses(info_points:Array):
	info_points_global = info_points
	for point in info_points:
		var i = point[0]
		var j = point[1]
		if point[2]:
			while j<buttons_array[i].size() and buttons_array[i][j].square_type == "white":
				if j+1 < buttons_array[i].size() and buttons_array[i][j+1].square_type == "white":
					buttons_array[i][j].to_right = buttons_array[i][j+1]
				j+=1
		else:
			while i<buttons_array.size() and buttons_array[i][j].square_type == "white":
				if i+1 < buttons_array.size() and buttons_array[i+1][j].square_type == "white":
					buttons_array[i][j].to_down = buttons_array[i+1][j]
				i += 1

					


	

func info_points_sort(point_a:Array, point_b : Array):
	if point_a[2] and not point_b[2]:
		return true
	if not point_a[2] and point_b[2]:
		return false
	if point_a[2]:
		if point_a[0] == point_b[0]:
			return point_a[1] < point_b[1]
		return point_a[0] < point_b[0]
	else:
		if point_a[1] == point_b[1]:
			return point_a[0] < point_b[0]
		return point_a[1] < point_b[1]

func make_best_crossword(given_words:Array):
	crossword_checked = false
	var final_crossword = []
	var final_info_points = []
	var final_used_words = []
	var counter = 0
	for i in range(5):
		
		given_words.shuffle()
		var new_option = make_crossword(given_words)
		if counter<new_option[0]:
			counter = new_option[0]
			final_crossword = new_option[1]
			final_info_points = new_option[2]
			final_used_words = new_option[3]
	for f in final_info_points:
		if f[4].length() == 1:
			final_info_points.erase(f)
	given_words.sort()
	show_crossword(final_crossword, final_info_points)
	tip_text = "Used Words:\n"
	final_used_words.sort()
	for word in final_used_words:
		tip_text = tip_text + word
		if word != final_used_words[-1]:
			tip_text = tip_text + ", "
	hiding_cells()
	update_solution()
	
func make_crossword(given_words:Array):
	var pion = 12
	var poziom = 24
	var crossword_array = []
	var info_points = []
	var words_used = []
	for i in range(pion):
		var new_line = []
		for j in range(poziom):
			new_line.append(" ")
		crossword_array.append(new_line)
	
	var first_word = given_words[0]
	while first_word[0].length() > 12:
		first_word = given_words.pick_random()[0]
	info_points.append([0,10,false,1,first_word[1]])
	words_used.append(first_word[0])
	for i in range(first_word[0].length()):
		crossword_array[i][10] = first_word[0][i]
		
	
	var words_counter = 0
	for g in given_words:
		if g[0] == first_word[0]:
			continue	
		var point = try_add_word(crossword_array,g[0])
		if point:
			words_counter += 1
			point.append(g[1])
			info_points.append(point)
			words_used.append(g[0])
	
	return [words_counter, crossword_array, info_points, words_used]
	"""
	for line in final_crossword:
		var new_line = %CrossLine.duplicate()
		new_line.visible = true
		%CrossWord.add_child(new_line)
		for letter in line:
			var new_letter = %CrossButton.duplicate()
			new_letter.visible = true
			if letter == " ":
				new_letter.square_type = "black"
			else:
				new_letter.square_type = "white"
				new_letter.set_text(letter)
			new_line.add_child(new_letter)
	"""
		


func try_add_word(crossword_array:Array, word:String):
	var possible_places = []
	#HORIZONTAL
	for i in range(crossword_array.size()):
		for j in range(crossword_array[i].size() - word.length()):
			var is_okay = true
			var is_crossing = false
			var crossing_points = 0
			if j > 0 and crossword_array[i][j-1] != " ":
				continue
			if j + word.length() < crossword_array[0].size() and crossword_array[i][j+word.length() ] != " ":
				continue
			for k in range(word.length()):
				if not crossword_array[i][j+k] in [word[k]," "]:
					is_okay = false
				if crossword_array[i][j+k] == " " and ((i>0 and crossword_array[i-1][j+k] != " ") or (i<crossword_array.size()-1 and crossword_array[i+1][j+k] != " ")):
						is_okay = false
				if crossword_array[i][j+k] == word[k]:
					is_crossing = true
					crossing_points += 1
			if is_okay and is_crossing and crossing_points!=word.length():
				possible_places.append([i,j,true,crossing_points])
	
	#VERTICAL
	for j in range(crossword_array[0].size()):
		for i in range(crossword_array.size() - word.length()):
			var is_okay = true
			var is_crossing = false
			var crossing_points = 0
			if i > 0 and crossword_array[i-1][j] != " ":
				continue
			if i + word.length() < crossword_array.size() and crossword_array[i+word.length()][j] != " ":
				continue
			for k in range(word.length()):
				if not crossword_array[i+k][j] in [word[k]," "]:
					is_okay = false
				if crossword_array[i+k][j] == " " and ((j>0 and crossword_array[i+k][j-1] != " ") or (j<crossword_array[0].size()-1 and crossword_array[i+k][j+1] != " ")):
						is_okay = false
				if crossword_array[i+k][j] == word[k]:
					is_crossing = true
					crossing_points += 1
			if is_okay and is_crossing and crossing_points!=word.length():
				possible_places.append([i,j,false,crossing_points])
	
	if possible_places.size() == 0:
		return false
	
	#DODAJ SŁOWO
	possible_places.sort_custom(points_sort)
	var point = possible_places[0]#possible_places.pick_random()
	if point[2]:
		for i in range(word.length()):
			crossword_array[point[0]][point[1] + i] = word[i]
	else:
		for i in range(word.length()):
			crossword_array[point[0]+i][point[1]] = word[i]
	
	
	return possible_places[0]
func points_sort(array_a, array_b):
	return array_a[3] > array_b[3]
	
	

func glue_two_words(first_word : String, second_word : String):
	var possible_cross_points = []
	for i in range(first_word.length()):
		for j in range(second_word.length()):
			if first_word[i] == second_word[j]:
				possible_cross_points.append([i,j])


func load_array():
	if not FileAccess.file_exists("user://FiszkiGerman.json"):
		print("File not found!")
		return []
	
	var file = FileAccess.open("user://FiszkiGerman.json", FileAccess.READ)
	var json_string = file.get_as_text()  # Read the file content
	file.close()
	
	var json = JSON.parse_string(json_string)  # Convert JSON back to array
	return json if json is Array else []
	


func choose_new_words():
	var words_for_crossword = []
	while words_for_crossword.size() < 10:
		var new_word = BIG_ARRAY.pick_random()
		if new_word[0].split(" ").size() > 1:
			if new_word[0].split(" ").size() == 2 and new_word[0].split(" ")[0].to_upper() in ["DIE", "DAS", "DER"]:
				new_word[0] = new_word[0].split(" ")[1]
			else:
				continue
		if new_word in words_for_crossword:
			continue
		new_word[0] = new_word[0].to_upper()
		words_for_crossword.append(new_word)
	given_words = words_for_crossword
	return words_for_crossword

func _on_new_words_pressed():
	delete_old_crossword()
	var words_for_crossword = choose_new_words()
	make_best_crossword(words_for_crossword)


func _on_new_crossword_pressed():
	delete_old_crossword()
	given_words.shuffle()
	make_best_crossword(given_words)

func delete_old_crossword():
	%ShowTips.visible = true
	%GivenWordsLabel.visible = false


func _on_check_crossword_pressed():
	if crossword_checked:
		return
	crossword_checked = true
	check_words()
	show_words_points()
	var new_points = check_solution()
	for word in info_points_global:
		new_points += word[5]
	if new_points>0:
		%NewPoints.text = "+ " + str(new_points) + "p!"
	score += new_points
	for line in buttons_array:
		for button in line:
			button.check()
	for child in %SolutionContainer.get_children():
		if child.has_node("Input") and child != %HasloCrossSample:
			child.check()
	if new_points==0:
		return
	await get_tree().create_timer(2).timeout
	%NewPoints.text = ""
	%Score.text = str(score) + "p"
	%Score.label_settings.font_color = Color.MEDIUM_SPRING_GREEN
	await get_tree().create_timer(1).timeout
	%Score.label_settings.font_color = Color.WHITE


func _on_show_tips_pressed():
	%ShowTips.visible = false
	%GivenWordsLabel.visible = true
	%GivenWordsLabel.text = tip_text
	check_words()


func _on_back_pressed():
	closed.emit()

func check_words():
	var points = 0
	for word in info_points_global:
		if word.size() == 5:
			word.append(0)
		var is_ok = true
		var x = word[0]
		var y = word[1]
		if word[2]:
			while y < buttons_array[0].size() and is_ok and buttons_array[x][y].square_type=="white":
				if buttons_array[x][y].correct_letter != buttons_array[x][y].get_node("Input").text:
					is_ok = false
				y = y+1
		else:
			while x < buttons_array.size() and is_ok and buttons_array[x][y].square_type=="white":
				if buttons_array[x][y].correct_letter != buttons_array[x][y].get_node("Input").text:
					is_ok = false
				x = x+1
		if is_ok:
			points += 1
			word[5] += 5
			if %ShowTips.visible:
				word[5] += 5
	return
	
func check_solution():
	var last_one = %GivenWordsLabel
	var is_okay_solution = true
	for child in %SolutionContainer.get_children():
		if not child.has_node("Input"):
			continue
		last_one = child
		if child.get_node("Input").text != child.correct_letter:
			is_okay_solution = false
	if is_okay_solution:
		if not %GivenWordsLabel.visible:
			last_one.show_score_horizontal(20)
			return 20
		else:
			last_one.show_score_horizontal(10)
			return 10
		
	return 0

func show_words_points():
	for word in info_points_global:
		if word[5] == 0:
			continue
		var x = word[0]
		var y = word[1]
		var is_horizontal = word[2]
		if is_horizontal:
			while y+1 < buttons_array[x].size() and buttons_array[x][y+1].square_type == "white":
				y += 1
			buttons_array[x][y].show_score_horizontal(word[5])
		else:
			while x+1 < buttons_array.size() and buttons_array[x+1][y].square_type == "white":
				x += 1
			buttons_array[x][y].show_score_vertical(word[5])
