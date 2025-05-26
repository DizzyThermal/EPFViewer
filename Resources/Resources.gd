extends Node

var tile_size := 48
var tile_size_vector := Vector2i(tile_size, tile_size)
var tile_rect := Rect2i(0, 0, tile_size, tile_size)
var palette_color_count := 256

var data_dir := Database.get_config_item_value("data_dir")
var desktop_dir := ""

# TODO: See if this is problematic for future items
var offset_range: Array[int] = []

enum EntityType {
	Player,
	Monster,
	NPC,
}

enum Totem {
	JUJAK = 0,
	BAEKHO = 1,
	HYUNMOO = 2,
	CHUNGRYONG = 3,
}

enum Gender {
	MALE = 0,
	FEMALE = 1,
}

enum Direction {
	UP = 0,
	RIGHT = 1,
	DOWN = 2,
	LEFT = 3,
}

func _init():
	if OS.get_name() == "Windows":
		desktop_dir = OS.get_environment("USERPROFILE") + "/Desktop/"
	else:
		desktop_dir = OS.get_environment("HOME") + "/Desktop/"

	# Generate Offset Range
	for i in range(48, 144):
		offset_range.append(i)
	for i in range(176, 256):
		offset_range.append(i)

static func arrays_intersect(
		array_1: Array[int],
		array_2: Array[int]) -> bool:
	var intersected := false

	for item in array_1:
		if item in array_2:
			intersected = true
			break
	
	return intersected
