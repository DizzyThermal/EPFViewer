class_name PartAnimation extends Node

var animation_index: int
var unknown_bytes: PackedByteArray = PackedByteArray()
var animation_frames: Array[PartAnimationFrame] = []

func _init(
		p_animation_index: int,
		p_unknown_bytes: PackedByteArray,
		p_animation_frames: Array[PartAnimationFrame]):
	self.animation_index = p_animation_index
	self.unknown_bytes.append_array(p_unknown_bytes)
	self.animation_frames.append_array(p_animation_frames)
