extends Area2D

signal rooms_overlap
signal room_generate

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var already_spawned = false
var spawner = null
var spawner_ray = null

var impossible = Array()
var spawned = Array()

var rooms
var rooms_node
var previous_size


func _ready():
	$col.shape.extents = Vector2(7, 7)
#	reprocess_impossible()
	for ray in get_self_rays():
		ray.force_raycast_update()
#		print(name, " ", ray.name, " ", is_really_colliding(ray))
		if ray.is_colliding():
			impossible.append(ray.name)
			ray.enabled = false
	
	connect("area_entered", self, "_on_area_entered")
	connect("rooms_overlap", rooms_node.get_parent(), "_on_rooms_overlap")
	connect("room_generate", rooms_node.get_parent(), "_on_rooms_generate")
	
	pass
	# Called when the node is added to the scene for the first time.
	# Initialization here
#	var rays = get_self_rays()
##	print(name, " ", rays.size())
#	for ray in rays:
#		ray.force_raycast_update()
##		print(name, " ", ray.name, " ", is_really_colliding(ray))
#		if is_really_colliding(ray):
#			impossible.append(ray)
#			ray.enabled = false
#		else:
#			var t = Timer.new()
#			t.wait_time = 0.2
#			t.name = "timer"
#			add_child(t)
#			$timer.connect("timeout", self, "_on_timer_timeout")
#			$timer.start()

func _process(delta):
	
	if Input.is_action_just_pressed("next_step"):
		generate_new_rooms()
	


func is_really_colliding(ray):
	return ray.is_colliding() and spawner != null and ray.get_collider().name != spawner.name

func get_self_rays():
	var rays = Array()
	for child in get_children():
		if "ray" in child.name:
			rays.append(child)
	return rays

func deactivate_rays():
	for ray in get_self_rays():
		ray.enabled = false
func activate_rays():
	for ray in get_self_rays():
		ray.enabled = true
		ray.exclude_parent = true


func can_ray_generate(ray):
	return impossible.find(ray.name) < 0 


func get_random_room(rooms, ray):
	var room = null
	
	var chance = randi() % 100 + 1
	var minus = 0
#	print(chance)
#	if chance <= 99:
#		minus = 6
#	if chance <= 5:
#		minus = 3
		
#	print(rooms.right_enter.size())
	
	if "left" in ray.name:
		room = rooms.right_enter[randi() % rooms.right_enter.size() - minus]
	if "top" in ray.name:
		room = rooms.bot_enter[randi() % rooms.bot_enter.size() - minus]
	if "right" in ray.name:
		room = rooms.left_enter[randi() % rooms.left_enter.size() - minus]
	if "bot" in ray.name:
		room = rooms.top_enter[randi() % rooms.top_enter.size() - minus]
	
#	if room != null:
#		var roo = room.duplicate()
#		return roo
	return room


func reprocess_impossible():
	activate_rays()
	impossible = Array()
	for ray in get_self_rays():
		ray.force_raycast_update()
		
#		if ray.is_colliding():
#			print(ray.get_collider().name, " ", spawner.name, " ", ray.name)
#			if spawner !=null and ray.get_collider().name != spawner.name and !(ray.name in spawned):
#				modulate = Color(0, 0, 0, 1)
		
		if ray.is_colliding() and ray.get_collider().name != spawner.name and !(ray.name in spawned):
			impossible.append(ray.name)
			ray.enabled = false
		if ray.is_colliding() and ray.get_collider().name == spawner.name and !(ray.name in spawned):
			ray.enabled = false
	if impossible.size() > 0:
		modulate = Color(.5, .9, .5, 1)
#		modulate = Color(.9, .5, .5, 1)


func generate_new_rooms():
#	self.rooms = rooms
#	self.rooms_node = rooms_node
##	self.spawner = spawner
	if !already_spawned:
		for ray in get_self_rays():
			if can_ray_generate(ray) and ray.enabled:
				var room = get_random_room(rooms, ray).duplicate()
				if room != null:
					spawned.append(ray.name)
					room.position = position + ray.cast_to
					room.spawner = self
					room.set_generator(rooms, rooms_node, self, ray)
					rooms_node.add_child(room)
#		print(impossible)
		deactivate_rays()
	already_spawned = true
	emit_signal("room_generate", rooms_node.get_children().size())

func set_generator(rooms, rooms_node, spawner, spawner_ray):
	self.rooms = rooms
	self.rooms_node = rooms_node
	self.spawner = spawner
	self.spawner_ray = spawner_ray
#	self.previous_size = previous_size
	
	
	
#	generate_new_rooms(rooms, )
	


func get_all_colliders():
	var arr = Array()
	
	activate_rays()
	for ray in get_self_rays():
		if ray.name != spawner_ray.name:
			ray.force_raycast_update()
			if ray.is_colliding():
				arr.append(ray.get_collider())
	
	return arr

func get_all_colliding_rays():
	var arr = Array()
	
	activate_rays()
	for ray in get_self_rays():
		if ray.name != spawner_ray.name:
			ray.force_raycast_update()
			if ray.is_colliding():
				arr.append(ray)
	
	return arr
	

func get_ray_collider(ray_name):
	var ray = get_node(ray_name)
	ray.enabled = true
	ray.force_raycast_update()
	print(ray.is_colliding())
	if ray.is_colliding():
		var collider = ray.get_collider()
		ray.enabled = false
		return collider
	ray.enabled = false
	return null

func _on_area_entered(area):
	emit_signal("rooms_overlap",self, area)


func _on_timer_timeout():
	$timer.stop()
