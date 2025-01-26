class_name EpfFileHandler extends NTK_FileHandler

const NTK_Frame = preload("res://DataTypes/NTK_Frame.gd")

var HEADER_SIZE := 0xC
var FRAME_SIZE := 0x10
var STENCIL_MASK := 0x80

var frame_count := 0
var frames := {}

var width := 0
var height := 0
var unknown := 0
var pixel_data_length := 0

func _init(file):
	super(file)
	frame_count = read_s16()
	width = read_s16()
	height = read_s16()
	unknown = read_s16()
	pixel_data_length = read_u32()

func get_frame(frame_index: int, read_mask=true, debug_frame: int=-1) -> NTK_Frame:
	# Frame Cache
	if frame_index in frames:
		return frames[frame_index]
	
	# Read to Frame Data
	file_position = HEADER_SIZE + pixel_data_length + (frame_index * FRAME_SIZE)
	var top := read_s16()
	var left := read_s16()
	var bottom := read_s16()
	var right := read_s16()
	
	var width := right - left
	var height := bottom - top
	
	var pixel_data_offset := read_u32()
	var mask_data_offset := read_u32()
	
	# Read Pixel Data
	file_position = HEADER_SIZE + pixel_data_offset
	var raw_pixel_data := read_bytes(width * height)

	# Read Mask Data
	var mask_byte_array := PackedByteArray()
	mask_byte_array.resize(width * height * 4)
	file_position = HEADER_SIZE + mask_data_offset
	var byte_offset := 0
	for i in range(height):
		var total_pixels := 0
		while true:
			var pixel_count := read_u8()
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

	var mask_image := Image.create_from_data(width, height, false, Image.FORMAT_RGBA8, mask_byte_array)

	var frame := NTK_Frame.new(left, top, right, bottom, width, height, raw_pixel_data, mask_image)
	frames[frame_index] = frame

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
		if Debug.debug_show_pixel_mask_data and frame.mask_image:
			print("DEBUG:     Mask Image Bytes:", frame.mask_image.get_data())

	return frames[frame_index]
