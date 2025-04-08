class_name PalFileHandler extends NTK_FileHandler

const Palette = preload("res://DataTypes/Palette.gd")

var header_size := 0
var palette_count := 1

var palettes: Array[Palette] = []

func _init(file):
	super(file)
	
	var file_position: int = 0
	var header := read_u32(file_position)

	if header != 1632652356:  # DLPalette (represented as u32)
		palette_count = read_u32(file_position)
		file_position += 4
		header_size = 4

	for i in range(palette_count):
		var pal_header := read_utf8(file_position, 9)
		file_position += 9
		var unknown_bytes_1 := read_bytes(file_position, 15)
		file_position += 15
		var animation_range_count := read_s8(file_position)
		file_position += 1
		var unknown_bytes_2 := read_bytes(file_position, 7)
		file_position += 7
		var animation_ranges := []
		var animation_indices: Array[int] = []
		for j in range(animation_range_count):
			var min_index := read_u8(file_position)
			file_position += 1
			var max_index := read_u8(file_position)
			file_position += 1
			animation_ranges.append({
				"min_index": min_index,
				"max_index": max_index,
			})
			animation_indices.append_array(range(min_index, max_index + 1))
		var colors: Array[Color] = []
		for j in range(Resources.palette_color_count):
			var color := Color.hex(read_u32be(file_position))
			file_position += 4
			colors.append(color)
		var palette = Palette.new(colors, animation_ranges, animation_indices, unknown_bytes_1, unknown_bytes_2)
		if i in Debug.debug_pal_indices:
			print("            DEBUG: Palette Index: ", i)
			print("            DEBUG: Palette Unknown Bytes 1: ", palette.unknown_bytes_1)
			print("            DEBUG: Palette Animation Range Count: ", animation_range_count)
			print("            DEBUG: Palette Animation Ranges: ", palette.animation_ranges)
			print("            DEBUG: Palette Unknown Bytes 2: ", palette.unknown_bytes_2)
		palettes.append(palette)

func get_palette(palette_index, set_alpha=255) -> Palette:
	var palette: Palette = palettes[palette_index] if palette_index < len(palettes) else null
	if palette and set_alpha:
		palette.set_alpha(set_alpha)

	return palette
