extends Area2D

signal rooms_overlap

var impossible = Array()

var creator_point = null

var opaques = Dictionary()

func _ready():
	collision_layer = 1
	collision_mask = 1
	$col.shape.extents = Vector2(7, 7)
	
	opaques["left"] = "right"
	opaques["right"] = "left"
	opaques["top"] = "bot"
	opaques["bot"] = "top"
	
	connect("area_entered", self, "_on_room_area_enter")


func _process(delta):
	pass


func Generate(ls, ts, rs, bs, rooms, fn):
	for point in $cons.get_children():
		point.owner_room = self
		point.Generate(ls, ts, rs, bs, rooms, fn)
		
func _on_room_area_enter(area):
	if "room" in area.name:
#		print(name, area.name)
		modulate = Color(1, 0, 0, 1)
		emit_signal("rooms_overlap", self, area)

func _on_point_enter_room(point):
	var point_room = point.owner_room
	if point_room.name != name:
		impossible.append(point.name)
		print(name, impossible)
		modulate = Color(.7,.9, .7, 1)
	pass
#	if creator_point != null and point_name != creator_point.name:
#		impossible.append(point_name)
#		print(name, impossible)
#		modulate = Color(.7,.9, .7, 1)