extends RayCast2D

var RayTypes = {"ray_left": "L", "ray_top": "T", "ray_right": "R", "ray_bot": "B"}

var Entrances = {"ray_left": "R", "ray_top": "B", "ray_right": "L", "ray_bot": "T"}


var ray_type

func _ready():
	ray_type = RayTypes[name]
	enabled = true




func is_currently_colliding():
	force_raycast_update()
	return is_colliding()


func get_current_collider():
	if is_currently_colliding():
		return get_collider()
	return null
	

func get_required_entrance():
	return Entrances[name]