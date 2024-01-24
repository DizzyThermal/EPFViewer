class_name NTK_Effect extends Node

const NTK_EffectFrame = preload("res://DataTypes/NTK_EffectFrame.gd")

var effect_index := -1
var frame_count := 0
var effect_frames: Array[NTK_EffectFrame] = []
func _init(
		effect_index: int,
		frame_count: int,
		effect_frames: Array[NTK_EffectFrame]):
	self.effect_index = effect_index
	self.frame_count = frame_count
	self.effect_frames.append_array(effect_frames)
