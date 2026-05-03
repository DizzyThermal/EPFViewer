class_name DatFileHandler extends NTK_FileHandler

const HEADER: int = 4
const FILE_NAME_LENGTH: int = 12

var file_count: int = 0
var files: Array[DatFile] = []

func _init(file):
	super(file)
	var file_position: int = 0

	file_count = read_u32(file_position) - 1
	file_position += 4

	for i in range(file_count):
		var start_data_location := read_u32(file_position)
		file_position += 4
		var file_name: String = read_utf8(file_position, FILE_NAME_LENGTH)
		file_position += FILE_NAME_LENGTH
		var _unknown: int = read_u8(file_position)
		file_position += 1
		var next_file_position: int = file_position
		var end_data_location: int = read_u32(file_position)
		file_position += 4
		var size: int = end_data_location - start_data_location
		file_position = start_data_location
		var file_data: PackedByteArray = file_bytes.slice(file_position, file_position + size)
		files.append(DatFile.new(file_name, file_data, start_data_location, end_data_location, size))
		file_position = next_file_position

func contains_file(file_name: String, exact=false) -> bool:
	for file in files:
		var fName1: String = file.file_name if exact else file.file_name.to_lower()
		var fName2: String = file_name if exact else file_name.to_lower()
		if fName1 == fName2:
			return true

	return false

func get_file(file_name: String, exact=false) -> PackedByteArray:
	for file in files:
		var fName1: String = file.file_name if exact else file.file_name.to_lower()
		var fName2: String = file_name if exact else file_name.to_lower()
		if fName1 == fName2:
			return file.data

	return PackedByteArray()

func get_file_names() -> Array[String]:
	var file_names: Array[String] = []
	for file in files:
		file_names.append(file.file_name)

	return file_names
