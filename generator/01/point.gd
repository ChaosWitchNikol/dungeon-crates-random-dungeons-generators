extends Area2D

signal point_enter_exiting_room

var ls
var ts
var rs
var bs
var rooms
var fn


var room = null
var owner_room
var impossible = Array()

var should_generate = true

func _ready():
	collision_layer = 2
	collision_mask = 1 + 2
	
	$timer.start()
	
	self.connect("area_entered", self, "_on_point_area_entered")
	$timer.connect("timeout", self, "_on_timer_timeout")

func _process(delta):
	
	if Input.is_action_just_pressed("next_step"):
		if should_generate:
			generate_room()
	
	if room != null or !should_generate:
		visible = false
#	if room != null:
#		visible = false

func generate_room():
	var ro = null
	
	if "left" in name:
		ro = ls[randi() % ls.size()]
	if "top" in name:
		ro = ts[randi() % ts.size()]
	if "right" in name:
		ro = rs[randi() % rs.size()]
	if "bot" in name:
		ro = bs[randi() % bs.size()]
	
	var roo = ro.duplicate()
	roo.creator_point = self
	self.room = roo
	
#	var cons = roo.get_node("cons")
#	if "left" in name:
#		cons.get_node("right").queue_free()
#	if "top" in name:
#		cons.get_node("bot").queue_free()
#	if "right" in name:
#		cons.get_node("left").queue_free()
#	if "bot" in name:
#		cons.get_node("top").queue_free()

	
	
	roo.position = global_position
	roo.connect("rooms_overlap", fn, "_on_rooms_overlap")
	roo.Generate(ls, ts, rs, bs, rooms, fn)
	connect_room_points_signals(roo)
	
	rooms.add_child(roo)


func connect_room_points_signals(room):
	for p in room.get_node("cons").get_children():
		p.connect("point_enter_exiting_room", room, "_on_point_enter_room")

func Generate(ls, ts, rs, bs, rooms, fn):
	var timer = Timer.new()
	timer.name = "timer"
	timer.wait_time = 0.2
	timer.one_shot = true
	add_child(timer)
	
	self.ls = ls
	self.ts = ts
	self.rs = rs
	self.bs = bs
	self.rooms = rooms
	
	self.fn = fn


func _on_point_area_entered(area):
	if "room" in area.name:
		should_generate = false
		print("==============================")
		print(area.name, " ", owner_room.name)
		if area.name != owner_room.name:
			emit_signal("point_enter_exiting_room", self)
			print(area.name, " ", owner_room.name)
		
func _on_timer_timeout():
#	if should_generate:
#		generate_room()
	$timer.stop()


func _on_point_enter_room(point_name):
	impossible.append(point_name)
	print(room.name, impossible)