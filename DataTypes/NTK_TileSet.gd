class_name NTK_TileSet extends Node

const NTK_TileSetSource = preload("res://DataTypes/NTK_TileSetSource.gd")

var tile_set_sources := {}

func add_tile_set_source(
		tile_index: int,
		tile_set_source: NTK_TileSetSource) -> void:
	tile_set_sources[tile_index] = tile_set_source
