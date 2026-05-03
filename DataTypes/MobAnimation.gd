class_name MobAnimation extends Node


var animation_frame_count: int
var animation_frames: Array[MobAnimationFrame] = []

func _init(
		p_animation_frame_count: int,
		p_animation_frames: Array[MobAnimationFrame]):
	self.animation_frame_count = p_animation_frame_count
	self.animation_frames.append_array(p_animation_frames)
