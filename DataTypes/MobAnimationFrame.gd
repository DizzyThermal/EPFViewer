class_name MobAnimationFrame extends Node

var frame_offset := -1
var duration := -1
var unknown_id_1 := -1
var alpha := -1
var unknown_id_2 := -1
var unknown_id_3 := -1

func _init(
		frame_offset: int,
		duration: int,
		unknown_id_1: int,
		alpha: int,
		unknown_id_2: int,
		unknown_id_3: int,):
	self.frame_offset = frame_offset
	self.duration = duration
	self.unknown_id_1 = unknown_id_1
	self.alpha = alpha
	self.unknown_id_2 = unknown_id_2
	self.unknown_id_3 = unknown_id_3
