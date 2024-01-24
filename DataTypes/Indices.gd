extends Node

var epf_index := -1
var frame_index := -1

func _init(frame_index: int, epfs: Array[EpfFileHandler]):
	var total_frames := 0
	for i in range(len(epfs)):
		if frame_index < total_frames + epfs[i].frame_count:
			epf_index = i
			self.frame_index = frame_index - total_frames
			break
		total_frames += epfs[i].frame_count
