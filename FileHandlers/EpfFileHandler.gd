class_name EpfFileHandler extends NTK_FileHandler

const NTK_Frame = preload("res://DataTypes/NTK_Frame.gd")

const HEADER_SIZE := 0xC
const FRAME_SIZE := 0x10
const STENCIL_MASK := 0x80

var frame_count := 0
var frames: Dictionary[int, NTK_Frame] = {}

var width := 0
var height := 0
var unknown := 0
var pixel_data_length := 0

func _init(file):
	super(file)
	
	var file_position: int = 0
	frame_count = read_s16(file_position)
	file_position += 2
	width = read_s16(file_position)
	file_position += 2
	height = read_s16(file_position)
	file_position += 2
	unknown = read_s16(file_position)
	file_position += 2
	pixel_data_length = read_u32(file_position)
	file_position += 4

func get_frame(
		frame_index: int,
		read_mask: bool=true,
		debug_attempt: int=1,
		debug_attempt_limit: int=5) -> NTK_Frame:
	# Frame Cache
	if frame_index in self.frames:
		return self.frames[frame_index]

	# Read to Frame Data
	var file_position: int = HEADER_SIZE + pixel_data_length + (frame_index * FRAME_SIZE)
	var top := read_s16(file_position)
	file_position += 2
	var left := read_s16(file_position)
	file_position += 2
	var bottom := read_s16(file_position)
	file_position += 2
	var right := read_s16(file_position)
	file_position += 2
	
	var width := right - left
	var height := bottom - top
	
	var pixel_data_offset := read_u32(file_position)
	file_position += 4
	var mask_data_offset := read_u32(file_position)
	file_position += 4
	
	# Read Pixel Data
	file_position = HEADER_SIZE + pixel_data_offset
	var raw_pixel_data_length := width * height
	var raw_pixel_data := read_bytes(file_position, raw_pixel_data_length)
	file_position += raw_pixel_data_length

	# Read Mask Data
	var mask_byte_array := PackedByteArray()
	mask_byte_array.resize(width * height * 4)
	file_position = HEADER_SIZE + mask_data_offset
	var byte_offset := 0
	for i in range(height):
		var total_pixels := 0
		while true:
			var pixel_count := read_u8(file_position)
			file_position += 1
			if pixel_count == 0x0:
				break

			var should_draw := false
			if pixel_count > STENCIL_MASK:
				should_draw = true

			if should_draw:
				pixel_count = pixel_count ^ STENCIL_MASK

			var pixel_color := Color.BLACK if should_draw else Color.TRANSPARENT
			for j in range(pixel_count):
				mask_byte_array.encode_u32(byte_offset, pixel_color.to_abgr32())
				byte_offset += 4
				total_pixels += 1

		if total_pixels < width:
			for j in range(width - total_pixels):
				mask_byte_array.encode_u32(byte_offset, Color.TRANSPARENT.to_abgr32())
				byte_offset += 4

	var mask_image: Image
	if width > 0 and height > 0:
		mask_image = Image.create_from_data(width, height, false, Image.FORMAT_RGBA8, mask_byte_array)

	var frame := NTK_Frame.new(left, top, right, bottom, width, height, raw_pixel_data, mask_image)
	mutex.lock()
	self.frames[frame_index] = frame
	mutex.unlock()

	if frame_index in Debug.debug_frame_indices:
		print("DEBUG: EPF Frame[", frame_index, "]:")
		print("DEBUG:   EPF Info:")
		print("DEBUG:     Width: ", self.width)
		print("DEBUG:     Height: ", self.height)
		print("DEBUG:     Unknown: ", self.unknown)
		print("DEBUG:     Pixel Data Length: ", self.pixel_data_length)
		print("DEBUG:   Frame Info:")
		print("DEBUG:     Dimensions (LTRB): ", [frame.left, frame.top, frame.right, frame.bottom])
		print("DEBUG:     Dimensions (WxH):  ", frame.width, " x ", frame.height)
		if Debug.debug_show_pixel_data:
			print("DEBUG:     Raw Pixel Bytes: ", frame.raw_pixel_data.to_int32_array())
		if Debug.debug_show_pixel_mask_data and frame.mask_image != null:
			print("DEBUG:     Mask Image Bytes:", frame.mask_image.get_data())

	if frame_index not in self.frames:
		print_rich("\n  [b][color=orange][WARNING][/color]: frame_index: '%s' not in self.frames![/b]\n" % frame_index)
		get_frame(
			frame_index,
			read_mask,
			debug_attempt + 1
		)
	if frame_index not in self.frames and debug_attempt > debug_attempt_limit:
		print_rich("\n  [b][color=red][ERROR][/color]: frame_index: '%s' not in self.frames after %d attempts![/b]\n" % frame_index, debug_attempt_limit)
		assert(false)

	return self.frames[frame_index] if frame_index in self.frames else frame
