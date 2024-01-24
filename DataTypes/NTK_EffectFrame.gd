class_name NTK_EffectFrame extends Node

var frame_index := -1
var frame_delay := 0
var palette_index := 0
var unknown := 0

func _init(
		frame_index: int,
		frame_delay: int,
		palette_index: int,
		unknown: int):
	self.frame_index = frame_index
	self.frame_delay = frame_delay
	self.palette_index = palette_index
	self.unknown = unknown
