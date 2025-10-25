extends Node

var epf_index: int = -1
var frame_index: int = -1
var total_frames: int = 0

func _init(global_frame_index: int, epfs: Array[EpfFileHandler]):
	for i in range(len(epfs)):
		if global_frame_index < self.total_frames + epfs[i].frame_count:
			self.epf_index = i
			self.frame_index = global_frame_index - self.total_frames
			break
		self.total_frames += epfs[i].frame_count
