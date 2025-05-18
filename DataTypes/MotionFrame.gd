class_name MotionFrame extends Node

var unknown_frame_short: int
var part_layer_ids: Array[NTK_Animations.PartLayer] = []

func _init(
		unknown_frame_short: int,
		part_layer_ids: Array[NTK_Animations.PartLayer]):
	self.unknown_frame_short = unknown_frame_short
	self.part_layer_ids.append_array(part_layer_ids)
