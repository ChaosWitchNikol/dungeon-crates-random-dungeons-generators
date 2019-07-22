extends Node2D

var Floor = preload("res://floor.tscn").instance()

var dungeon_themes = ["crypt"]
var dungeon_names = {
	"crypt": {
		"second": ["crypt", "dungeon", "catacombs", "cave", "grotto", "grave", "tomb"],
		"first": ["Cruel", "Dark", "Brutal", "Vicious", "Evil", "Kastramath's", "Diablo's"],
		"other": ["of suffering", "of bitterness", "of evil", "of torture"]
	}
}




var levels = 1
var min_rooms = 7
var max_rooms = 13

var all_floors = Array()

func _ready():
	randomize()
	generate_dungeon_floors()
	
	print(get_dungeon_dictionary())

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass



func generate_dungeon_floors():
#	var fl = Floor.instance()
#	add_child(fl)
	var index = 0
	while index < levels:
		var fl = Floor.duplicate()
#		fl.preprocess_floor()
		add_child(fl)
		var rooms_count = fl.get_rooms_count()
		print(rooms_count)
		if rooms_count >= min_rooms and rooms_count <= max_rooms:
			index += 1
			all_floors.append(fl.get_floor_dictionary(index))
		remove_child(fl)
		fl.queue_free()
		


func generate_dungeon_theme():
	return dungeon_themes[randi() % dungeon_themes.size()]

func generate_dungeon_name(theme):
	var names = dungeon_names[theme]
	var chance_of_other = randi() % 100 + 1
	
	var dungeon_name = names.first[randi() % names.first.size()]
	dungeon_name += " " + names.second[randi() % names.second.size()]
	
	if chance_of_other <= 33:
		dungeon_name += " " + names.other[randi() % names.other.size()]
	
	return dungeon_name


func preset_dungeon(levels, min_rooms, max_rooms):
	self.levels = levels
	self.min_rooms = min_rooms
	self.max_rooms = max_rooms


func get_dungeon_dictionary():
	var dict = Dictionary()
	
	var theme = generate_dungeon_theme()
	dict["dungeon_theme"] = theme
	dict["dungeon_name"] = generate_dungeon_name(theme)
	dict["floors"] = all_floors
	
	return dict