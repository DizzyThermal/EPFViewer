class_name Motion extends Node

var id: int
var motion_name: String
var unknown_int: int
var frame_count: int

var motion_frames: Array[MotionFrame] = []

func _init(
		p_id: int,
		p_motion_name: String,
		p_unknown_int: int,
		p_frame_count: int,
		p_motion_frames: Array[MotionFrame]):
	self.id = p_id
	self.motion_name = p_motion_name
	self.unknown_int = p_unknown_int
	self.frame_count = p_frame_count
	self.motion_frames.append_array(p_motion_frames)
