class_name SObjTblFileHandler extends NTK_FileHandler

# SObj - Static Objects
const SObj = preload("res://DataTypes/SObj.gd")

var TBL_MASK := 0x7F

var object_count := 0
var objects := {}

func _init(file):
	super(file)
	
	var file_position: int = 0
	object_count = read_u32(file_position)
	file_position += 4
	
	var unknown_short := read_u16(file_position)
	file_position += 2
	
	# Objects
	for i in range(object_count):
		var unknown_bytes := read_bytes(file_position, 5)
		file_position += 5
		var collision := read_u8(file_position)
		file_position += 1
		var height := read_u8(file_position)
		file_position += 1
		var tile_indices: Array[int] = []
		for j in range(height):
			tile_indices.append(read_u16(file_position))
			file_position += 2
		objects[i] = SObj.new(collision, height, tile_indices)
