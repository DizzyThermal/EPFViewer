class_name NTK_TileSetSource extends Node

var tile_set_width := 40

var tile_atlas_position := Vector2i(0, 0)
var tile_indices_by_position = {}
var tile_atlas_position_by_tile_index = {}

var tile_set_atlas_source: TileSetAtlasSource = null

func add_tile(position: Vector2i, tile_index: int) -> void:
	tile_indices_by_position[position] = tile_index
	if tile_index not in tile_atlas_position_by_tile_index:
		tile_atlas_position_by_tile_index[tile_index] = tile_atlas_position
		if tile_atlas_position.x >= tile_set_width:
			tile_atlas_position.x = 0
			tile_atlas_position.y = tile_atlas_position.y + 1
		else:
			tile_atlas_position.x = tile_atlas_position.x + 1
