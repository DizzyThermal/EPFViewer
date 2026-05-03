class_name DatFile extends Node

var file_name: String
var data: PackedByteArray = PackedByteArray()
var start_data_location: int
var end_data_location: int
var size: int

func _init(
		p_file_name: String,
		p_data: PackedByteArray,
		p_start_data_location: int,
		p_end_data_location: int,
		p_size: int) -> void:
	self.file_name = p_file_name
	self.data.append_array(p_data)
	self.start_data_location = p_start_data_location
	self.end_data_location = p_end_data_location
	self.size = p_size
