class_name NTK_EffectFrame extends Node

var frame_index: int
var frame_delay: int
var palette_index: int = 0
var unknown: int = 0	# Loop Flag?

func _init(
		p_frame_index: int,
		p_frame_delay: int,
		p_palette_index: int,
		p_unknown: int) -> void:
	self.frame_index = p_frame_index
	self.frame_delay = p_frame_delay
	self.palette_index = p_palette_index
	self.unknown = p_unknown
