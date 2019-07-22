extends Node


const L = preload("res://images/L.png")
const T = preload("res://images/T.png")
const R = preload("res://images/R.png")
const B = preload("res://images/B.png")
const LT = preload("res://images/LT.png")
const LR = preload("res://images/LR.png")
const LB = preload("res://images/LB.png")
const TR = preload("res://images/TR.png")
const TB = preload("res://images/TB.png")
const RB = preload("res://images/RB.png")
const LTR = preload("res://images/LTR.png")
const LTB = preload("res://images/LTB.png")
const LRB = preload("res://images/LRB.png")
const TRB = preload("res://images/TRB.png")
const LTRB = preload("res://images/entry.png")
const EM = preload("res://images/EM.png")

const ROOMS = {"L": L, "T": T, "R": R, "B": B, 
"LT": LT, "LR": LR, "LB": LB, "TR": TR, "TB": TB, "RB":RB, 
"LTR":LTR, "LTB": LTB, "LRB": LRB, "TRB": TRB, 
"LTRB": LTRB, "EM": EM}


var Gen2 = preload("res://gen2.gd").new()

const DIFF = "easy"

var floor_index = 0
var floors

func _ready():
	randomize()
	floors = Gen2.generate(DIFF)
	print(floors)
	place_rooms(floors[0])

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _input(event):
	if event.is_action_pressed("ui_accept"):
		remove_rooms()
		floor_index += 1
		if floor_index == floors.size():
			floors = Gen2.generate(DIFF)
			floor_index = 0
		place_rooms(floors[floor_index])


func remove_rooms():
	for child in get_children():
		child.queue_free()


func place_rooms(dung_floor):
	var entrance = place_room(dung_floor.entrance)
	entrance.modulate = Color(0, 1, 0)
	var extreme = place_room(dung_floor.extreme)
	extreme.modulate = Color(1, 0, 0)
	for room in dung_floor.rooms:
		place_room(room)
	
func place_room(room):
	var sprite = Sprite.new()
	sprite.texture = ROOMS[room.type]  
	sprite.scale = Vector2(3, 3)
	sprite.position = room.position * 48 + Vector2(32, 32)
	add_child(sprite)
	return sprite