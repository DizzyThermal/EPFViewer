extends Node

var ab_index: int = -1
var unpassable_tile: bool = false
var sobj_index: int = -1

func _init(
		p_ab_index: int,
		p_unpassable_tile: bool,
		p_sobj_index: int):
	self.ab_index = p_ab_index
	self.unpassable_tile = p_unpassable_tile
	self.sobj_index = p_sobj_index
