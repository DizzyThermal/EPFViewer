class_name NTK_FileHandler extends Node

var file_bytes := PackedByteArray()
var file_position := 0
var file_size := 0

func _init(file, directory=Resources.data_dir):
	file_bytes = file if file is PackedByteArray else FileAccess.get_file_as_bytes(directory + "/" + file)
	file_size = len(file_bytes)

func read_bytes(length: int) -> PackedByteArray:
	var read_value := file_bytes.slice(file_position, file_position + length)
	file_position += length
	
	return read_value

func read_s8() -> int:
	var read_value := file_bytes.decode_s8(file_position)
	file_position += 1
	
	return read_value

func read_s16() -> int:
	var read_value := file_bytes.decode_s16(file_position)
	file_position += 2
	
	return read_value

func read_s32() -> int:
	var read_value := file_bytes.decode_s32(file_position)
	file_position += 4
	
	return read_value

func read_u8() -> int:
	var read_value := file_bytes.decode_u8(file_position)
	file_position += 1
	
	return read_value

func read_u16() -> int:
	var read_value := file_bytes.decode_u16(file_position)
	file_position += 2
	
	return read_value

func read_u32() -> int:
	var read_value := file_bytes.decode_u32(file_position)
	file_position += 4
	
	return read_value
	
func read_u32be() -> int:
	var int_bytes := file_bytes.slice(file_position, file_position + 4)
	file_position += 4
	int_bytes.reverse()
	
	return int_bytes.decode_u32(0)

func read_utf8(length: int = 0) -> String:
	if not length:
		var read_value := file_bytes.get_string_from_utf8()
		file_position += len(read_value)
		return read_value
		
	var byte_slice := file_bytes.slice(file_position, file_position + length)
	file_position += length

	return byte_slice.get_string_from_utf8()

func read_utf16(length: int = 0) -> String:
	if not length:
		var read_value := file_bytes.get_string_from_utf16()
		file_position += len(read_value) * 2
		return read_value
		
	var byte_slice := file_bytes.slice(file_position, file_position + (length * 2))
	file_position += (length * 2) + 2

	return byte_slice.get_string_from_utf16()
