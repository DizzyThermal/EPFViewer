class_name SObj extends Node

var collision: int
var height: int
var tile_indices: Array[int] = []

func _init(
		p_collision: int,
		p_height: int,
		p_tile_indices: Array[int]):
	self.collision = p_collision
	self.height = p_height
	self.tile_indices.append_array(p_tile_indices)
