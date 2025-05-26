class_name NTK_FileHandler extends Node

var file_bytes := PackedByteArray()
var file_size := 0

var mutex: Mutex = Mutex.new()

func _init(file, data_directory=Resources.data_dir):
	if file is PackedByteArray:
		file_bytes = file
	elif "/" in file or "\\" in file:
		file_bytes = FileAccess.get_file_as_bytes(file)
	else:
		file_bytes = FileAccess.get_file_as_bytes(data_directory + "/" + file)

	file_size = len(file_bytes)

func read_bytes(file_position: int, length: int) -> PackedByteArray:
	var read_value := file_bytes.slice(
		file_position,
		file_position + length)
	
	return read_value

func read_s8(file_position: int) -> int:
	var read_value := file_bytes.decode_s8(file_position)
	
	return read_value

func read_s16(file_position: int) -> int:
	var read_value := file_bytes.decode_s16(file_position)
	
	return read_value

func read_s32(file_position: int) -> int:
	var read_value := file_bytes.decode_s32(file_position)
	
	return read_value

func read_u8(file_position: int) -> int:
	var read_value := file_bytes.decode_u8(file_position)
	
	return read_value

func read_u16(file_position: int) -> int:
	var read_value := file_bytes.decode_u16(file_position)
	
	return read_value

func read_u32(file_position: int) -> int:
	var read_value := file_bytes.decode_u32(file_position)
	
	return read_value
	
func read_u32be(file_position: int) -> int:
	var int_bytes := file_bytes.slice(
		file_position,
		file_position + 4)
	int_bytes.reverse()
	
	return int_bytes.decode_u32(0)

func read_utf8(file_position: int, length: int = 0) -> String:
	if not length:
		var read_value := file_bytes.get_string_from_utf8()
		return read_value
		
	var byte_slice := file_bytes.slice(
		file_position,
		file_position + length)
	
	return byte_slice.get_string_from_utf8()

func read_utf16(file_position: int, length: int = 0) -> String:
	if not length:
		var read_value := file_bytes.get_string_from_utf16()
		return read_value
		
	var byte_slice := file_bytes.slice(
		file_position,
		file_position + (length * 2))
	
	return byte_slice.get_string_from_utf16()
