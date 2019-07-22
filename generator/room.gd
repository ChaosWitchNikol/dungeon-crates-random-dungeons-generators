extends Area2D


var RaysToEntrance = {"L":"R", "T":"B", "R": "L", "B":"T"}
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var entrances = Array()

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	pass

func has_entrance(entrance):
	return get_entrances().has(entrance)
	
func get_entrances():
	var arr = Array()
	for ray in get_rays():
		arr.append(ray.ray_type)
	return arr

func get_rays():
	var arr = Array()
	for child in get_children():
		if "ray" in child.name:
			arr.append(child)
	return arr

#	all rays which can spawn new room
func rays_to_process():
	var arr = Array()
	for ray in get_rays():
		if !ray.is_currently_colliding():
			arr.append(ray)
	return arr

func get_rays_string():
	var result = ""
	for ray in get_rays():
		result += ray.ray_type
	
	return result



func get_room_dictionary():
	var dict = Dictionary()
	
	dict["type"] = get_rays_string()
	dict["position"] = position / 16 
	
	return dict

