class_name MotionTblFileHandler extends NTK_FileHandler

const Motion = preload("res://DataTypes/Motion.gd")
const MotionFrame = preload("res://DataTypes/MotionFrame.gd")

const NAME_LENGTH := 0x15
const FRAME_SIZE := 0x7A
const MAX_FRAMES := 0x1E

var motion_count := 0
var motions := {}

func _init(file):
	super(file)

	var file_position: int = NAME_LENGTH	# "MotionStandard       "
	var unknown_short := read_u16(file_position)
	file_position += 2
	motion_count = read_u32(file_position)
	file_position += 4
	if Debug.debug_motions:
		print("DEBUG: Motion Count: ", motion_count)

	for i in range(motion_count):
		var id := read_u32(file_position)
		file_position += 4
		var motion_name := read_utf8(file_position, NAME_LENGTH)
		file_position += NAME_LENGTH
		var unknown_int := read_u32(file_position)
		file_position += 4
		var frame_count := read_u32(file_position)
		file_position += 4
		var motion_frames: Array[MotionFrame] = []
		for j in range(frame_count):
			var next_file_position := file_position + FRAME_SIZE
			var unknown_frame_short := read_s16(file_position)
			file_position += 2
			var part_layer_ids: Array[NTK_Animations.PartLayer] = []
			for k in range(MAX_FRAMES):
				var part_layer_id := read_s32(file_position)
				file_position += 4
				if part_layer_id == -1:
					file_position = next_file_position
					break
				part_layer_ids.append(part_layer_id)
			motion_frames.append(
				MotionFrame.new(unknown_frame_short, part_layer_ids))
		motions[i] = Motion.new(id, motion_name, unknown_int, frame_count, motion_frames)

		if Debug.debug_motions:
			print("DEBUG: Motion [", id, "]:")
			print("DEBUG:   Motion Info:")
			print("DEBUG:     Motion Name: ", motion_name)
			print("DEBUG:     Unknown Int: ", unknown_int)
			print("DEBUG:     Frame Count: ", frame_count)
			for idx in range(len(motion_frames)):
				var motion_frame := motion_frames[idx]
				print("DEBUG:     Motion Frames [", idx, "]:")
				print("DEBUG:       Unknown: ", motion_frame.unknown_frame_short)
				print("DEBUG:       Part Layer Ids: ", motion_frame.part_layer_ids)
