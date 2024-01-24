class_name MobAnimation extends Node

const MobAnimationFrame = preload("res://DataTypes/MobAnimationFrame.gd")

var animation_frame_count := -1
var animation_frames: Array[MobAnimationFrame] = []

func _init(
		animation_frame_count: int,
		animation_frames: Array[MobAnimationFrame]):
	self.animation_frame_count = animation_frame_count
	self.animation_frames.append_array(animation_frames)
