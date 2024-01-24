extends Node

var file_name := ""
var data := PackedByteArray()
var start_data_location := 0
var end_data_location := 0
var size := 0

func _init(file_name: String, data: PackedByteArray, start_data_location: int, end_data_location: int, size: int):
	self.file_name = file_name
	self.data.append_array(data)
	self.start_data_location = start_data_location
	self.end_data_location = end_data_location
	self.size = size
