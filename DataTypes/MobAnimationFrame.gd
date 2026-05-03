class_name MobAnimationFrame extends Node

var frame_offset: int
var duration: int
var unknown_id_1: int
var alpha: int
var unknown_id_2: int
var unknown_id_3: int

func _init(
		p_frame_offset: int,
		p_duration: int,
		p_unknown_id_1: int,
		p_alpha: int,
		p_unknown_id_2: int,
		p_unknown_id_3: int) -> void:
	self.frame_offset = p_frame_offset
	self.duration = p_duration
	self.unknown_id_1 = p_unknown_id_1
	self.alpha = p_alpha
	self.unknown_id_2 = p_unknown_id_2
	self.unknown_id_3 = p_unknown_id_3
