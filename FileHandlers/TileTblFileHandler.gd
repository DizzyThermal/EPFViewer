class_name TileTblFileHandler extends NTK_FileHandler

var TBL_MASK := 0x7F

var tile_count := 0
var palette_indices: Array[int] = []

func _init(file):
	super(file)
	tile_count = read_u32()
	
	for i in range(tile_count):
		var lsb := read_u8()
		var msb := read_u8()
		var palette_index := ((msb & TBL_MASK) << 8) | lsb

		palette_indices.append(palette_index)
