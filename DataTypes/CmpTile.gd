extends Node

var ab_index := -1
var unpassable_tile := false
var sobj_index := -1

func _init(ab_index: int, unpassable_tile: bool, sobj_index: int):
	self.ab_index = ab_index
	self.unpassable_tile = unpassable_tile
	self.sobj_index = sobj_index
