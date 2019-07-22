extends Node2D

signal generate

var entrance = preload("res://rooms/entrance.tscn").instance()

var L = preload("res://rooms/L.tscn").instance()
var T = preload("res://rooms/T.tscn").instance()
var R = preload("res://rooms/R.tscn").instance()
var B = preload("res://rooms/B.tscn").instance()

var LT = preload("res://rooms/LT.tscn").instance()
var LR = preload("res://rooms/LR.tscn").instance()
var LB = preload("res://rooms/LB.tscn").instance()
var TR = preload("res://rooms/TR.tscn").instance()
var TB = preload("res://rooms/TB.tscn").instance()
var RB = preload("res://rooms/RB.tscn").instance()

var LTR = preload("res://rooms/LTR.tscn").instance()
var LTB = preload("res://rooms/LTB.tscn").instance()
var LRB = preload("res://rooms/LRB.tscn").instance()
var TRB = preload("res://rooms/TRB.tscn").instance()

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var rooms = Dictionary()


var prev_size = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	process_rooms_variable()
	
	var entr = entrance.duplicate()
	entr.set_generator(rooms, $rooms, null, null)
	add_child(entr)
#	entr.generate_new_rooms(rooms, $rooms, null)
#	var e2 = entrance.duplicate()
#	e2.position = Vector2( 16, 0);
#	e2.spawner = entr
#	add_child(e2.duplicate())
	
	var t = Timer.new()
	t.name = "postprocess"
	t.wait_time = 1
	add_child(t)
	
	$postprocess.connect("timeout", self, "_on_postprocess_timeout")
	
	
	var inter = Array(rooms.left_imp)
	print("========")
	print(inter)
	print("========")
	inter = intersect(inter, rooms.top_imp)
	print(inter)
	inter = intersect(inter, rooms.right_imp)
	print("========")
	print(inter)
	
	for room in inter:
		for ray in room.get_self_rays():
			print(ray.name)
	pass

func _process(delta):
	pass
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
#	if Input.is_action_just_pressed("reset_rooms"):
#		get_node("entrance").queue_free()
#		var entr = entrance.duplicate()
#		entr.set_generator(rooms, $rooms, entr)
#		add_child(entr)
#	pass

func process_rooms_variable():
	rooms["all"] = Array()
	rooms.all = [L, T, R, B,  LT, LR, LB, TR, TB, RB,  LTR, LTB, LRB, TRB]
	
	rooms["left_enter"] = [L, L,L,L,L, LT,LT, LR,LR, LB,LB, LTR, LTB, LRB]
	rooms["top_enter"] = [T,T,T,T,T, LT,LT, TR,TR, TB,TB, LTR, LTB, TRB]
	rooms["right_enter"] = [R,R,R,R,R, LT,LT, TR,TR, RB,RB, LTR, LRB, TRB]
	rooms["bot_enter"] = [B,B,B,B,B, LB,LB, TB,TB, RB, RB,LTB, LRB, TRB]
	
	# which are possible when side is impossible
	rooms["left_imp"] = [T, R, B, TR, TB, RB, TRB]
	rooms["top_imp"] = [L, R, B, LR, LB, RB, LRB]
	rooms["right_imp"] = [L, T, B, LT, LB, TB, LTB]
	rooms["bot_imp"] = [L, T, R, LT, LR, TR, LTR]
	
	print(rooms)

func intersect(arr1, arr2):
	var intersection = Array()
	
	for item in arr1:
		if arr2.has(item):
			intersection.append(item)
			
	return intersection


var oposite_rays = Dictionary()


func postprocess_rooms():
	oposite_rays["ray_left"] = "ray_right"
	oposite_rays["ray_top"] = "ray_bot"
	oposite_rays["ray_right"] = "ray_left"
	oposite_rays["ray_bot"] = "ray_top"
	
	print("==========")
	for room in $rooms.get_children():
#		room.print_tree_pretty()
		room.reprocess_impossible()
		print(room.spawner.name, " ", room.spawner_ray.name, " ", room.impossible, room.spawned)
		
		var nam = ""
		for ray in room.get_self_rays():
			if "left" in ray.name:
				nam += "L"
			if "top" in ray.name:
				nam += "T"
			if "right" in ray.name:
				nam += "R"
			if "bot" in ray.name:
				nam += "B"
		
		print(nam);
	
		for imp in room.impossible:
			var col = room.get_ray_collider(imp)
			if col != null:
				if col.has_node(oposite_rays[imp]):
					print("has this opening ", imp)
				else:
					print("not this opening ", imp)
					if "left" in imp:
						nam = remove_from_string(nam, "L")
					if "top" in imp:
						nam = remove_from_string(nam, "T")
					if "right" in imp:
						nam = remove_from_string(nam, "R")
					if "bot" in imp:
						nam = remove_from_string(nam, "B")
					
					print("========")
					print(nam)
					
					var pos = col.position
					col.queue_free()
					var new_room = rooms.all[rooms.all.find(nam)].duplicate()
					new_room.deactivate_rays()
					new_room.position = pos
					new_room.set_generator(rooms, $rooms, null, null)
					$rooms.add_child(new_room)
					
		
		if room.impossible.size() > 0:
			room.modulate = Color(.5, .5, 1, 1)
#	for room in get_impossible_rooms():
#		for collider in room.get_all_colliding_rays():
#			print(collider.name)


func remove_from_string(source, character):
	var index = source.find(character)
#	print(source)
	return source.replace(character, "")
#	print(source)




func get_impossible_rooms():
	var arr = Array()
	
	for room in $rooms.get_children():
		if room.impossible.size() > 0:
			arr.append(room)
	
	return arr






func _on_rooms_overlap(room1, room2):
	var rooms = $rooms.get_children()
	var index1 = rooms.find(room1)
	var index2 = rooms.find(room2)
#	print(index1, " ", index2)
	if index1 < index2:
		var remove = rooms[index2]
#		rooms.remove(index2)
		remove.spawner.spawned.erase(remove.spawner_ray.name)
		remove.queue_free()
		rooms[index1].modulate = Color(.7, .7, .9, 1)
		rooms[index1].reprocess_impossible()
	else:
		var remove = rooms[index1]
#		rooms.remove(index1)
		remove.spawner.spawned.erase(remove.spawner_ray.name)
		remove.queue_free()
		rooms[index2].modulate = Color(.7, .7, .9, 1)
		rooms[index2].reprocess_impossible()
#	prev_size = 0
#	_on_rooms_generate()

func _on_postprocess_timeout():
	print("postprocess")
	postprocess_rooms()
	$postprocess.stop()

func _on_rooms_generate(size):
	var s = $rooms.get_children().size()
	if s != prev_size || size != s:
		prev_size = $rooms.get_children().size()
		$postprocess.stop()
	else:
		$postprocess.start()
#		print("postprocess")