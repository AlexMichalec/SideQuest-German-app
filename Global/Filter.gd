extends Node

func by_date(BIG_ARRAY : Array = Utility.load_array(), index:int = 0, date_string:String = "", to_date:String = "", show_whole = false):
	var dates_array = []
	BIG_ARRAY.sort_custom(date_sort)
	var temp_date = BIG_ARRAY[0]["date_added"].left(10)
	dates_array.append([temp_date])
	for b in BIG_ARRAY:
		if b["date_added"].left(10) == temp_date:
			dates_array[-1].append(b)
		else:
			temp_date = b["date_added"].left(10)
			dates_array.append([temp_date])
			dates_array[-1].append(b)
			
	if show_whole:
		return dates_array
			
	if to_date != "":
		var result = []
		var cur_index = 0 
		while dates_array[cur_index][0]> to_date:
			var temp = dates_array[cur_index]
			temp.pop_front()
			result.append_array(temp)
			cur_index += 1
		return result

	var result :Array = dates_array[index]
	result.pop_front()
	return result
	"""
	print(dates_array.size())
	for d in dates_array:
		if d.size() >4:
			print(d[0]," ",d[1]["original"], " ",d[2]["original"], " ", d[3]["original"], "  ", d.size())
		elif d.size() == 2:
			print(d[0]," ",d[1]["original"])
		else:
			print(d[0], " ", d.size())
		print("")
	"""
	
func date_sort(a:Dictionary,b:Dictionary):
	return a["date_added"] > b["date_added"]
