extends Node2D

var FloorGen = preload("res://gen3/floor.tscn")

const EASY = "easy"
const NORMAL = "normal"
const HARD = "hard"
const NIGHTMARE = "nightmare"

const SIZES_EASY = [Vector2(3, 4), Vector2(4, 3)]
const SIZES_NORMAL = [Vector2(3, 5), Vector2(4, 4), Vector2(4, 5), Vector2(5, 3), Vector2(5, 4)]
const SIZES_HARD = [Vector2(4, 5), Vector2(5, 4), Vector2(5, 5), Vector2(5, 6), Vector2(6, 5)]
const SIZES_NIGHTMARE = [Vector2(6, 6), Vector2(6, 7),  Vector2(7, 6)]
var SIZES = { EASY: SIZES_EASY, NORMAL: SIZES_NORMAL, HARD: SIZES_HARD, NIGHTMARE: SIZES_NIGHTMARE }

const LEVELS_COUNT_EASY = [6, 9]
const LEVELS_COUNT_NORMAL = [8, 12]
const LEVELS_COUNT_HARD = [12, 16]
const LEVELS_COUNT_NIGHTMARE = [15, 20]
var LEVELS_COUNT = { EASY: LEVELS_COUNT_EASY, NORMAL: LEVELS_COUNT_NORMAL, HARD: LEVELS_COUNT_HARD, NIGHTMARE : LEVELS_COUNT_NIGHTMARE}


const ERASE_FRACTIONS_EASY = [0]
const ERASE_FRACTIONS_NORMAL = [0.1, 0.2]
const ERASE_FRACTIONS_HARD = [0.3, 0.4, 0.5]
const ERASE_FRACTIONS_NIGHTMARE = [0.6, 0.7, 0.8, 0.9]
var ERASE_FRACTIONS = { 
	EASY: ERASE_FRACTIONS_EASY,
	NORMAL: ERASE_FRACTIONS_NORMAL,
	HARD: ERASE_FRACTIONS_HARD,
	NIGHTMARE: ERASE_FRACTIONS_NIGHTMARE
}

# variables
var floors = Array()
var difficulty



func generate(difficulty = NORMAL):
	self.difficulty = difficulty
	floors = generate_floors()
	return floors

func generate_floors():
	var floors = Array()
	var possible_levels_count = LEVELS_COUNT[difficulty]
	var number_of_floors = randi() % (possible_levels_count[1] - possible_levels_count[0]) + possible_levels_count[0]
	for index in range(0, number_of_floors):
		floors.append(generate_one_floor(index))
	return floors


func generate_one_floor(floor_index):
	var fgen = FloorGen.instance()
	fgen.name = "floor%s" % str(floor_index + 1)
	add_child(fgen)
	
	var possible_sizes = SIZES[difficulty]
	var sizes = possible_sizes[randi() % possible_sizes.size()]
	
	var possible_erase_fractions = ERASE_FRACTIONS[difficulty]
	var erase_fraction = possible_erase_fractions[randi() % possible_erase_fractions.size()]
	
	var layout = fgen.generate_floorv(sizes, erase_fraction)
	
	
	var scheme = Dictionary()
	scheme["floor_number"] = floor_index + 1
	scheme["rooms"] = layout["rooms"]
	scheme["entrance"] = layout["entrance"]
	scheme["extreme"] = layout["extreme"]
	scheme["total_size"] = layout["rooms"].size() + 2
	
	return scheme

