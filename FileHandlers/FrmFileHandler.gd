class_name FrmFileHandler extends NTK_FileHandler

const HEADER := 0x4
const PALETTE_SIZE := 0x4

var effect_count := 0
var palette_indices: Array[int] = []

func _init(file):
	super(file)
	var file_position: int = 0
	
	effect_count = read_u32(file_position)
	file_position += 4

	for i in range(effect_count):
		palette_indices.append(read_u32(file_position))
		file_position += 4
