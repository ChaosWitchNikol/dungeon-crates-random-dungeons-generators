extends Node2D

var floor_map = preload("res://gen3/floor.tscn")

var Gen3 = preload("res://gen3/gen3.tscn")

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var timer_running = true

func _ready():
	randomize()
	var gen = Gen3.instance()
	gen.name = "gen"
	add_child(gen)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		var floors = get_node("gen").generate("easy")
		print(floors)
#		if timer_running:
#			$Timer.stop()
#			timer_running = false
#		else:
#			$Timer.start()
#			timer_running = true

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Timer_timeout():
	var floors = get_node("gen").generate("easy")
	print(floors)
	pass
#	get_node("map").generate_floor()

