class_name SObj extends Node

var collision: int = 0x0
var height: int = 0
var tile_indices: Array[int] = []

func _init(collision: int, height: int, tile_indices: Array[int]):
	self.collision = collision
	self.height = height
	self.tile_indices.append_array(tile_indices)
