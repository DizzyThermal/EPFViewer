class_name Part extends Node

var id: int
var palette_index: int
var frame_index: int
var frame_count: int
var unknown_bytes: PackedByteArray = PackedByteArray()
var animations: Dictionary = {}

func _init(
		p_id: int,
		p_palette_index: int,
		p_frame_index: int,
		p_frame_count: int,
		p_unknown_bytes: PackedByteArray,
		p_animations: Dictionary):
	self.id = p_id
	self.palette_index = p_palette_index
	self.frame_index = p_frame_index
	self.frame_count = p_frame_count
	self.unknown_bytes.append_array(p_unknown_bytes)
	self.animations = p_animations
