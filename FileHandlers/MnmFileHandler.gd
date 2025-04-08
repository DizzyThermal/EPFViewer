class_name MnmFileHandler extends NTK_FileHandler

var MNM_NAME_SIZE := 0x1F

var map_name := ""

var npc_count := 0
var npcs := []

var warp_count := 0
var warps := []

func _init(file_path):
	super(file_path)

	# Seek into the JPEG
	var file_position: int = 0x300

	# Find end of JPEG
	while true:
		var byte = read_u8(file_position)
		file_position += 1
		if byte == 0xFF:
			byte = read_u8(file_position)
			file_position += 1
			if byte == 0xD9:
				# End of JPEG (FF D9)
				break
			else:
				# Set file pointer back one
				file_position -= 1

	# Map Name Length
	var map_name_length = read_s32(file_position)
	file_position += 4
	map_name = read_utf16(map_name_length)

	# NPCs
	npc_count = read_s32(file_position)
	file_position += 4
	for i in range(npc_count):
		var npc_name = read_utf16(file_position, MNM_NAME_SIZE)
		file_position += MNM_NAME_SIZE
		var npc_map_x = read_s32(file_position)
		file_position += 4
		var npc_map_y = read_s32(file_position)
		file_position += 4
		npcs.append({
			'name': npc_name,
			'x_coord': npc_map_x,
			'y_coord': npc_map_y,
		})

	# Warp
	warp_count = read_s32(file_position)
	file_position += 4
	for i in range(warp_count):
		var warp_map_id = read_s32(file_position)
		file_position += 4
		var warp_map_name = read_utf16(file_position, MNM_NAME_SIZE)
		file_position += MNM_NAME_SIZE
		var warp_x = read_s32(file_position)
		file_position += 4
		var warp_y = read_s32(file_position)
		file_position += 4
		var warp_npc_count = read_s32(file_position)
		file_position += 4
		var warp_npcs := []
		for j in range(warp_npc_count):
			var warp_npc_name = read_utf16(file_position, MNM_NAME_SIZE)
			file_position += MNM_NAME_SIZE
			warp_npcs.append(warp_npc_name)

		warps.append({
			'map_id': warp_map_id,
			'map_name': warp_map_name,
			'x_coord': warp_x,
			'y_coord': warp_y,
			'npc_count': warp_npc_count,
			'npcs': warp_npcs
		})
