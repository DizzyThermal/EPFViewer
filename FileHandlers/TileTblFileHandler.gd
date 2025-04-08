class_name TileTblFileHandler extends NTK_FileHandler

const TBL_MASK := 0x7F

var tile_count := 0
var palette_indices: Array[int] = []

func _init(file):
	super(file)
	var file_position: int = 0
	
	tile_count = read_u32(file_position)
	file_position += 4
	
	for i in range(tile_count):
		var lsb := read_u8(file_position)
		file_position += 1
		var msb := read_u8(file_position)
		file_position += 1
		var palette_index := ((msb & TBL_MASK) << 8) | lsb
		
		palette_indices.append(palette_index)
