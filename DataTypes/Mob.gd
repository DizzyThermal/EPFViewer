class_name Mob extends Node

var frame_index: int
var animation_count: int
var unknown_byte: int
var palette_index: int
var animations: Array[MobAnimation] = []

func _init(
		p_frame_index: int,
		p_animation_count: int,
		p_unknown_byte: int,
		p_palette_index: int,
		p_animations: Array[MobAnimation]):
	self.frame_index = p_frame_index
	self.animation_count = p_animation_count
	self.unknown_byte = p_unknown_byte
	self.palette_index = p_palette_index
	self.animations.append_array(p_animations)
