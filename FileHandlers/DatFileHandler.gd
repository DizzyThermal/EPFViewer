class_name DatFileHandler extends NTK_FileHandler

const DatFile = preload("res://DataTypes/DatFile.gd")

var HEADER := 4
var FILE_NAME_LENGTH := 12

var file_count := 0
var files: Array[DatFile] = []

func _init(file):
	super(file)
	file_count = read_u32() - 1

	for i in range(file_count):
		var start_data_location := read_u32()
		var file_name := read_utf8(FILE_NAME_LENGTH)
		var unknown := read_u8()
		var next_file_position := file_position
		var end_data_location := read_u32()
		var size := end_data_location - start_data_location
		file_position = start_data_location
		var file_data := file_bytes.slice(file_position, file_position + size)
		files.append(DatFile.new(file_name, file_data, start_data_location, end_data_location, size))
		file_position = next_file_position

func contains_file(file_name: String, exact=false) -> bool:
	for file in files:
		var fName1 := file.file_name if exact else file.file_name.to_lower()
		var fName2 := file_name if exact else file_name.to_lower()
		if fName1 == fName2:
			return true

	return false

func get_file(file_name: String, exact=false) -> PackedByteArray:
	for file in files:
		var fName1 := file.file_name if exact else file.file_name.to_lower()
		var fName2 := file_name if exact else file_name.to_lower()
		if fName1 == fName2:
			return file.data

	return PackedByteArray()
