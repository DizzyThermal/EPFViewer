class_name NTK_TileRenderer extends NTK_Renderer

const TileTblFileHandler = preload("res://FileHandlers/TileTblFileHandler.gd")

var tbl: TileTblFileHandler = null

func _numeric_sort(a: String, b: String) -> bool:
	if int(a.replace("tile", "").replace("c", "").replace(".dat", "")) \
		< int(b.replace("tile", "").replace("c", "").replace(".dat", "")):
		return true
	return false

func _init(tile_regex="tile\\d+\\.dat", tile_pal="tile.pal", tile_tbl="tile.tbl"):
	var start_time := Time.get_ticks_msec()
	var ntk_data_directory := DirAccess.open(Resources.data_dir)

	# EPFs
	var tileDatRegex := RegEx.new()
	tileDatRegex.compile(tile_regex)

	var files: Array[String] = []
	for file_name in ntk_data_directory.get_files():
		var result := tileDatRegex.search(file_name)
		if result:
			files.append(file_name)
	files.sort_custom(_numeric_sort)
	for file_name in files:
		epfs.append(EpfFileHandler.new(DatFileHandler.new(file_name).get_file(file_name.replace("dat", "epf"))))

	var tile_dat := DatFileHandler.new("tile.dat")
	if not Debug.debug_pal_indices.is_empty():
		print(tile_pal)
	pal = PalFileHandler.new(tile_dat.get_file(tile_pal))
	tbl = TileTblFileHandler.new(tile_dat.get_file(tile_tbl))
	
	if Debug.debug_renderer_timings:
		var tile_prefix = tile_tbl.to_lower().replace(".tbl", "")
		print("[TileRenderer]: [", tile_prefix, "]: ", Time.get_ticks_msec() - start_time, " ms")

func create_ntk_tileset(
		tile_index_start: int=1,
		tile_count: int=2000,
		tile_break: int=40) -> NTK_TileSetSource:
	var ntk_tileset := NTK_TileSetSource.new()
	var atlas_width := tile_break
	var atlas_height := (tile_count / tile_break)
	for tile_index in range(tile_index_start, tile_index_start + tile_count):
		var tile_position := Vector2i((tile_index % atlas_width), (tile_index / atlas_width))
		var palette_index := tbl.palette_indices[tile_index]
		var image_key := String.num(tile_index) + "-" + String.num(palette_index)
		if image_key not in images:
			render_frame(tile_index, palette_index, false)
			ntk_tileset.add_tile(tile_position, tile_index)

	if len(ntk_tileset.tile_atlas_position_by_tile_index) < ntk_tileset.tile_set_width:
		ntk_tileset.tile_set_width = len(ntk_tileset.tile_atlas_position_by_tile_index)

	var tile_set_image_size = Vector2i(ntk_tileset.tile_set_width * Resources.tile_size, ntk_tileset.tile_atlas_position.y * Resources.tile_size)
	var tile_set_image = Image.create(tile_set_image_size.x, tile_set_image_size.y, false, Image.FORMAT_RGBA8)
	for tile_index in ntk_tileset.tile_atlas_position_by_tile_index:
		var palette_index := tbl.palette_indices[tile_index]
		var image_key := String.num(tile_index) + "-" + String.num(palette_index)
		var tile_position = ntk_tileset.tile_atlas_position_by_tile_index[tile_index]
		tile_set_image.blit_rect(images[image_key], Resources.tile_rect, tile_position * Resources.tile_size)

	var tile_set_atlas_source := TileSetAtlasSource.new()
	tile_set_atlas_source.texture = ImageTexture.create_from_image(tile_set_image)
	tile_set_atlas_source.texture_region_size = Resources.tile_size_vector
	for tile_index in ntk_tileset.tile_atlas_position_by_tile_index:
		var tile_position = ntk_tileset.tile_atlas_position_by_tile_index[tile_index]
		tile_set_atlas_source.create_tile(tile_position)

	ntk_tileset.tile_set_atlas_source = tile_set_atlas_source
	return ntk_tileset
