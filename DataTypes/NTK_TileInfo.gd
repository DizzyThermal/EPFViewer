class_name NTK_TileInfo extends Node

var tile_index := 0
var tile_coordinate := Vector2i(0, 0)

func _init(tile_index: int, tile_coordinate: Vector2i):
	self.tile_index = tile_index
	self.tile_coordinate = tile_coordinate
