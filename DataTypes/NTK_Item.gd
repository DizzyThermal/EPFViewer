class_name NTK_Item extends Node

var item_index: int
var palette_index: int
var unknown_int_1: int
var unknown_int_2: int
var unknown_int_3: int

func _init(
		item_index: int,
		palette_index: int,
		unknown_int_1: int,
		unknown_int_2: int,
		unknown_int_3: int) -> void:
	self.item_index = item_index
	self.palette_index = palette_index
	self.unknown_int_1 = unknown_int_1
	self.unknown_int_2 = unknown_int_2
	self.unknown_int_3 = unknown_int_3
