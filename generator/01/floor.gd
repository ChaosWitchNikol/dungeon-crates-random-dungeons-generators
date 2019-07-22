extends Node2D

var entry = preload("res://01/rooms/entry.tscn").instance()
var L = preload("res://01/rooms/L.tscn").instance()
var T = preload("res://01/rooms/T.tscn").instance()
var R = preload("res://01/rooms/R.tscn").instance()
var B = preload("res://01/rooms/B.tscn").instance()
var LT = preload("res://01/rooms/LT.tscn").instance()
var LR = preload("res://01/rooms/LR.tscn").instance()
var LB = preload("res://01/rooms/LB.tscn").instance()
var TB = preload("res://01/rooms/TB.tscn").instance()
var TR = preload("res://01/rooms/TR.tscn").instance()
var RB = preload("res://01/rooms/RB.tscn").instance()
var LTR = preload("res://01/rooms/LTR.tscn").instance()
var LTB = preload("res://01/rooms/LTB.tscn").instance()
var LRB = preload("res://01/rooms/LRB.tscn").instance()
var TRB = preload("res://01/rooms/TRB.tscn").instance()

var all_rooms = [entry, L,T, R, B, LR, TB, LTR, LTB, LRB, TRB]

# with left entrance
var right_rooms = [
	L, L, L, L, L, 
	LR, LR, LR, LR,
	LT, LT, LT, LT,
	LB, LB, LB, LB, 
	LTR, LTB, LRB
]
# with top entrance
var bot_rooms = [
	T, T, T, T, T, 
	TB, TB, TB, TB,
	LT, LT, LT, LT,
	TR, TR, TR, TR,
	LTR, LTB, TRB
]
# with right entrance
var left_rooms = [
	R, R, R, R, R,
	LR, LR, LR, LR,
	TR, TR, TR, TR,
	RB, RB, RB, RB,
	LTR, LRB, TRB
]
# with bot entrance
var top_rooms = [
	B, B, B, B, B,  
	TB, TB, TB, TB,
	LB, LB, LB, LB,
	RB, RB, RB, RB,
	LTB, LRB, TRB
]


func _ready():
	randomize()
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
#	for r in all_rooms:
#		r.connect("rooms_overlap", self, "_on_rooms_overlap")
	
	generate()


func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	
	if Input.is_action_just_pressed("reset_rooms"):
		generate()



func generate():
	for room in $rooms.get_children():
		room.queue_free()
	
	var start = entry.duplicate()
	start.Generate(left_rooms, top_rooms, right_rooms, bot_rooms, $rooms, self)
	$rooms.add_child(start)


func _on_rooms_overlap(room1, room2):
	var rooms = $rooms.get_children()
	var index1 = rooms.find(room1)
	var index2 = rooms.find(room2)
	print(index1, " ", index2)
	if index1 < index2:
		var remove = rooms[index2]
		rooms.remove(index2)
		remove.queue_free()
		rooms[index1].modulate = Color(.7, .7, .9, 1)
	else:
		var remove = rooms[index1]
		rooms.remove(index1)
		remove.queue_free()
		rooms[index2].modulate = Color(.7, .7, .9, 1)
	