class_name CmpFileHandler extends NTK_FileHandler

const CmpTile = preload("res://DataTypes/CmpTile.gd")

var map_id := -1
var map_name := ""
var width := 0
var height := 0
var tiles: Array[CmpTile] = []

func _init(
		map_id: int) -> void:
	super(("TK%06d.cmp" % map_id), Resources.map_dir)
	self.map_id = map_id
	file_position = 4  # CMAP

	var dims := read_u32()
	width = dims & 0x0000FFFF
	height = dims >> 0x10

	var compressed_data := read_bytes(file_size - 4)
	var map_data := compressed_data.decompress_dynamic(width * height * 6, FileAccess.COMPRESSION_DEFLATE)

	for i in range(int(len(map_data) / 6)):
		var idx := (i * 6)
		tiles.append(CmpTile.new(
			map_data.decode_u16(idx),
			bool(map_data.decode_u16(idx + 2)),
			map_data.decode_u16(idx + 4) - 1
		))

	if FileAccess.file_exists(Resources.mnm_dir + ("/%06d.mnm" % map_id)):
		var mnm := MnmFileHandler.new(map_id)
		map_name = mnm.map_name
