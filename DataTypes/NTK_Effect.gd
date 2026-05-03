class_name NTK_Effect extends Node

var effect_index: int
var frame_count: int
var effect_frames: Array[NTK_EffectFrame] = []
func _init(
		p_effect_index: int,
		p_frame_count: int,
		p_effect_frames: Array[NTK_EffectFrame]) -> void:
	self.effect_index = p_effect_index
	self.frame_count = p_frame_count
	self.effect_frames.append_array(p_effect_frames)
