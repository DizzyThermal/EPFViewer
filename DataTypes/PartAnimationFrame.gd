class_name PartAnimationFrames extends Node

var frame_offset := -1
var unknown_bytes := PackedByteArray()

func _init(
		frame_offset: int,
		unknown_bytes: PackedByteArray):
	self.frame_offset = frame_offset
	self.unknown_bytes.append_array(unknown_bytes)
