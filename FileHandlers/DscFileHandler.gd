class_name DscFileHandler extends NTK_FileHandler

const Part = preload("res://DataTypes/Part.gd")
const PartAnimation = preload("res://DataTypes/PartAnimation.gd")
const PartAnimationFrame = preload("res://DataTypes/PartAnimationFrame.gd")

var HEADER_SIZE := 0x17

var part_count := 0
var parts := {}

func _init(file):
	super(file)
	file_position = HEADER_SIZE

	part_count = read_u32()
	for i in range(part_count):
		var id := read_u32()
		var palette_index := read_u32()
		var frame_index := read_u32()
		var frame_count := read_u32()

		# Unknown Bytes
		var part_unknown_bytes := PackedByteArray(read_bytes(14))

		var animation_count := read_u32()
		var animations: Array[PartAnimation] = []
		for j in range(animation_count):
			var animation_index := read_s32()
			
			# Unknown Bytes
			var animation_unknown_bytes := PackedByteArray(read_bytes(4))

			var animation_frame_count := read_u32()
			var animation_frames: Array[PartAnimationFrame] = []
			for k in range(animation_frame_count):
				var frame_offset := read_s16()

				# Unknown Bytes
				var animation_frames_unknown_bytes := PackedByteArray(read_bytes(7))
				
				animation_frames.append(
					PartAnimationFrame.new(frame_offset, animation_frames_unknown_bytes))
			animations.append(
				PartAnimation.new(animation_index, animation_unknown_bytes, animation_frames))
		parts[i] = Part.new(id, palette_index, frame_index, frame_count, part_unknown_bytes, animations)

func print_part_info(part_index: int, part_name: String) -> void:
	print("\n", part_name, "[", part_index, "]:")
	print("  Palette Index: ", parts[part_index].palette_index)
	print("  Frame Index: ", parts[part_index].frame_index)
	print("  Frame Count: ", parts[part_index].frame_count)
	print("  Unknown Bytes: ", parts[part_index].unknown_bytes)
	print("\n  PartAnimation Count: ", len(parts[part_index].animations))
	for j in range(len(parts[part_index].animations)):
		print("\n    PartAnimation[", parts[part_index].animations[j].animation_index, "]:")
		print("      Unknown Bytes: ", parts[part_index].animations[j].unknown_bytes)
		print("      PartAnimationFrame Count: ", len(parts[part_index].animations[j].animation_frames))
		for k in range(len(parts[part_index].animations[j].animation_frames)):
			print("\n        PartAnimationFrame[", k, "]:")
			print("          Frame Offset: ", parts[part_index].animations[j].animation_frames[k].frame_offset)
			print("          Unknown Bytes: ", parts[part_index].animations[j].animation_frames[k].unknown_bytes)

