class_name MotionFrame extends Node

var unknown_frame_short: int
var part_layer_ids: Array[NTK_Animations.PartLayer] = []

func _init(
		p_unknown_frame_short: int,
		p_part_layer_ids: Array[NTK_Animations.PartLayer]):
	self.unknown_frame_short = p_unknown_frame_short
	self.part_layer_ids.append_array(p_part_layer_ids)
