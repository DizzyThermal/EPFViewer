class_name Motion extends Node

const MotionFrame = preload("res://DataTypes/MotionFrame.gd")

var id: int
var motion_name: String
var unknown_int: int
var frame_count: int

var motion_frames: Array[MotionFrame] = []

func _init(
		id: int,
		motion_name: String,
		unknown_int: int,
		frame_count: int,
		motion_frames: Array[MotionFrame]):
	self.id = id
	self.motion_name = motion_name
	self.unknown_int = unknown_int
	self.frame_count = frame_count
	self.motion_frames.append_array(motion_frames)
