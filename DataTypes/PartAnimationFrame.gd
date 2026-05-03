class_name PartAnimationFrame extends Node

var frame_offset: int
var unknown_bytes: PackedByteArray = PackedByteArray()

func _init(
		p_frame_offset: int,
		p_unknown_bytes: PackedByteArray):
	self.frame_offset = p_frame_offset
	self.unknown_bytes.append_array(p_unknown_bytes)
