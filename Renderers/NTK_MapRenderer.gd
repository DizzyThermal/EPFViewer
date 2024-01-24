class_name NTK_MapRenderer extends Node

const CmpFileHandler = preload("res://FileHandlers/CmpFileHandler.gd")
const SObj = preload("res://DataTypes/SObj.gd")
const NTK_TileSetSource = preload("res://DataTypes/NTK_TileSetSource.gd")

var tile_renderer: NTK_TileRenderer = null
var sobj_renderer: NTK_SObjRenderer = null

var cmp: CmpFileHandler = null
var map_id := -1
var objects := {}
var ntk_tileset_source := NTK_TileSetSource.new()

func _init():
	var start_time := Time.get_ticks_msec()
	tile_renderer = NTK_TileRenderer.new()
	sobj_renderer = NTK_SObjRenderer.new()
	
	if Debug.debug_renderer_timings:
		print("[MapRenderer]: ", Time.get_ticks_msec() - start_time, " ms")

func _load_map(map_id: int):
	if not cmp or self.map_id != map_id:
		self.map_id = map_id
		cmp = CmpFileHandler.new(map_id)

func render_map(parent: Node2D, map_id: int, render_objects: bool) -> void:
	_load_map(map_id)
	render_map_cropped(parent, map_id, 0, 0, cmp.width, cmp.height, render_objects)

func render_map_cropped(parent: Node2D, map_id: int, x: int, y: int, width: int, height: int, render_objects: bool=true) -> void:
	var start_time := Time.get_ticks_msec()
	_load_map(map_id)
	if width == 0 or height == 0:
		x = 0
		y = 0
		width = cmp.width
		height = cmp.height
	else:
		# Crop and adjust width/height if x/y are negative
		width = min(width, cmp.width) if x >= 0 else width - x
		height = min(height, cmp.height) if y >= 0 else height - y
		x = x if x >= 0 else 0
		y = y if y >= 0 else 0

	# Create TileMap (Ground)
	var tilemap_start_time := Time.get_ticks_msec()
	create_tilemap(parent, map_id, x, y, width, height)
	if Debug.debug_renderer_timings:
		print("[", ("TK%06d" % map_id), "]: Create TileMap: ", Time.get_ticks_msec() - tilemap_start_time, " ms")
	if render_objects:
		# Create Objects (Static Objects)
		var objects_start_time := Time.get_ticks_msec()
		create_objects(parent, map_id, x, y, width, height)
		if Debug.debug_renderer_timings:
			print("[", ("TK%06d" % map_id), "]: Create Objects: ", Time.get_ticks_msec() - objects_start_time, " ms")
	
	if Debug.debug_renderer_timings:
		print("[", ("TK%06d" % map_id), "]: ------- Loaded: ", Time.get_ticks_msec() - start_time, " ms\n")

func get_map_tile_indices(
		map_id: int,
		tile_indices) -> Array:
	for i in range(len(cmp.tiles)):
		var tile := cmp.tiles[i]
		var x := i % cmp.width
		var y := i / cmp.width
		tile_indices[y][x] = tile.ab_index

	return tile_indices

func get_tile_collision(coordinate: Vector2i) -> int:
	var tile_index := (coordinate.y * cmp.width) + coordinate.x
	if tile_index < 0 or tile_index >= len(cmp.tiles):
		return 0xF

	var unpassable_tile := cmp.tiles[tile_index].unpassable_tile
	if unpassable_tile:
		return 0xF

	var sobj_index := cmp.tiles[tile_index].sobj_index
	if sobj_index < 0:
		return 0x0

	var sobj := sobj_renderer.sobj
	return sobj.objects[sobj_index].collision

func create_tile_set_source(map_id: int):
	var map_id_str := String.num(map_id)
	for i in range(len(cmp.tiles)):
		var tile_position := Vector2i((i % cmp.width), (i / cmp.width))
		var tile_index := cmp.tiles[i].ab_index
		var palette_index = tile_renderer.tbl.palette_indices[tile_index]
		var image_key := String.num(tile_index) + "-" + String.num(palette_index)
		if image_key not in tile_renderer.images:
			tile_renderer.render_frame(tile_index, palette_index, false)
			ntk_tileset_source.add_tile(tile_position, tile_index)
	if map_id_str in NTK_Maps.Overlays:
		for overlay in NTK_Maps.Overlays[map_id_str]:
			if 'ab_index' in overlay:		
				var palette_index := tile_renderer.tbl.palette_indices[overlay.ab_index]
				var image_key := String.num(overlay.ab_index) + "-" + String.num(palette_index)
				if image_key not in tile_renderer.images:
					tile_renderer.render_frame(overlay.ab_index, palette_index, false)
					ntk_tileset_source.add_tile(overlay.location, overlay.ab_index)

	if len(ntk_tileset_source.tile_atlas_position_by_tile_index) < ntk_tileset_source.tile_set_width:
		ntk_tileset_source.tile_set_width = len(ntk_tileset_source.tile_atlas_position_by_tile_index)
	
	var num_of_tiles = len(ntk_tileset_source.tile_atlas_position_by_tile_index)
	var tile_set_image_size = Vector2i((ntk_tileset_source.tile_set_width + 1) * Resources.tile_size, (ntk_tileset_source.tile_atlas_position.y + 1) * Resources.tile_size)
	var tile_set_image = Image.create(tile_set_image_size.x, tile_set_image_size.y, false, Image.FORMAT_RGBA8)
	for tile_index in ntk_tileset_source.tile_atlas_position_by_tile_index:
		var tile_position = ntk_tileset_source.tile_atlas_position_by_tile_index[tile_index]
		var palette_index = tile_renderer.tbl.palette_indices[tile_index]
		var image_key := String.num(tile_index) + "-" + String.num(palette_index)
		tile_set_image.blit_rect(tile_renderer.images[image_key], Resources.tile_rect, tile_position * Resources.tile_size)

	var tile_set_source := TileSetAtlasSource.new()
	tile_set_source.texture = ImageTexture.create_from_image(tile_set_image)
	tile_set_source.texture_region_size = Resources.tile_size_vector
	for tile_index in ntk_tileset_source.tile_atlas_position_by_tile_index:
		var tile_position = ntk_tileset_source.tile_atlas_position_by_tile_index[tile_index]
		tile_set_source.create_tile(tile_position)

	return tile_set_source

func create_tile_set(map_id: int) -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = Resources.tile_size_vector

	var map_id_str := String.num(map_id)
	for i in range(len(cmp.tiles)):
		var tile_index := cmp.tiles[i].ab_index
		var palette_index = tile_renderer.tbl.palette_indices[tile_index]
		var image_key := String.num(tile_index) + "-" + String.num(palette_index)
		if image_key not in tile_renderer.images:
			var frame := tile_renderer.get_frame(tile_index)
			var palette := tile_renderer.pal.get_palette(palette_index)
			var tile_set_source := TileSetAtlasSource.new()
			tile_set_source.texture_region_size = Resources.tile_size_vector
			if palette.is_animated and \
					Resources.arrays_intersect(
						palette.animation_indices,
						frame.raw_pixel_data_array):
				var animation_count := len(palette.animation_indices) / len(palette.animation_ranges)
				tile_set_source.texture = ImageTexture.create_from_image(
					tile_renderer.render_animated_frame(tile_index,
						animation_count,
						palette_index,
						false))
				tile_set_source.create_tile(Vector2i(0, 0))
				tile_set_source.set_tile_animation_columns(Vector2i(0, 0), animation_count)
				tile_set_source.set_tile_animation_frames_count(Vector2i(0, 0), animation_count)
				for j in range(animation_count):
					tile_set_source.set_tile_animation_frame_duration(Vector2i(0, 0), j, 0.5)
			else:
				tile_set_source.texture = ImageTexture.create_from_image(
					tile_renderer.render_frame(
						tile_index,
						palette_index,
						false))
				tile_set_source.create_tile(Vector2i(0, 0))
			tile_set.add_source(tile_set_source, tile_index)
	if map_id_str in NTK_Maps.Overlays:
		for overlay in NTK_Maps.Overlays[map_id_str]:
			if 'ab_index' in overlay:
				var palette_index := tile_renderer.tbl.palette_indices[overlay.ab_index]
				var image_key := String.num(overlay.ab_index) + "-" + String.num(palette_index)
				if image_key not in tile_renderer.images:
					tile_renderer.render_frame(overlay.ab_index, palette_index, false)
	
	return tile_set

func create_tilemap(parent: Node2D, map_id: int, x: int, y: int, width: int, height: int) -> void:
	var tile_map: TileMap = parent.tile_map
	tile_map.clear()

	var tile_set: TileSet = TileSet.new()
	tile_set.tile_size = Resources.tile_size_vector
	tile_map.tile_set = create_tile_set(map_id)

	var map_area := Rect2i(x, y, width, height)
	var start_i: int = max(0, (y * cmp.width) + (x % cmp.width))
	var end_i: int = min(len(cmp.tiles), ((y + height) * cmp.width) + ((x + cmp.width) % cmp.width))
	var debug_image: Image = null
	if Debug.debug_map_tilemap:
		debug_image = Image.create(width * Resources.tile_size, height * Resources.tile_size, false,Image.FORMAT_RGBA8)
	for i in range(start_i, end_i):
		var tile_position := Vector2i((i % cmp.width), (i / cmp.width))
		if not map_area.has_point(tile_position):
			continue
		var ab_index := cmp.tiles[i].ab_index
		if tile_position in Debug.debug_tile_coords:
			print("[", ("TK%06d" % map_id), "]: DEBUG: Frame[", ab_index, "] (", tile_position.x, ", ", tile_position.y, ")")
		var frame = tile_renderer.get_frame(ab_index)
		if ab_index == 0:
			print("[", ("TK%06d" % map_id), "]: WARNING: Tile AB Index 0: ", tile_position.x, ", ", tile_position.y)
			continue
		if frame.width <= 0 or frame.height <= 0:
			print("[", ("TK%06d" % map_id), "]: WARNING: Tile[", ab_index, "] Tile Dims: ", frame.width, " x ", frame.height, " | Tile Coords: ", tile_position.x, ", ", tile_position.y)
			continue
		tile_map.set_cell(0, tile_position, ab_index, Vector2i(0, 0))

		if Debug.debug_tile_indices and ab_index in Debug.debug_tile_indices:
			print("DEBUG:  Tile[", ab_index, "]:")
			print("DEBUG:    Palette Index: ", tile_renderer.tbl.palette_indices[ab_index])

		# Overlay Tiles
		var map_id_str := String.num(map_id)
		if map_id_str in NTK_Maps.Overlays:
			for overlay in NTK_Maps.Overlays[map_id_str]:
				if 'ab_index' in overlay and overlay.location == tile_position:
					tile_map.set_cell(0, overlay.location, overlay.ab_index, Vector2i(0, 0))
					break

		if Debug.debug_map_tilemap:
			debug_image.blit_rect(
				tile_renderer.frames[ab_index],
				Rect2i(0, 0, frame.width, frame.height),
				Vector2i(
					(tile_position.x - x) * Resources.tile_size,
					(tile_position.y - y) * Resources.tile_size))
	if Debug.debug_map_tilemap:
		Debug.save_to_desktop(debug_image, "Map-" + String.num(map_id) + ".png")

func clear_objects(objects: Node2D):
	for object in objects.get_children():
		objects.remove_child(object)
		object.queue_free()

func create_object(parent: Node2D, sobj_index: int, location: Vector2i) -> void:
	if sobj_index not in objects:
		objects[sobj_index] = sobj_renderer.render_object(sobj_index)
	
	var sobj: SObj = sobj_renderer.sobj.objects[sobj_index]
	var sobj_height := sobj.height

	var obj_sprite := Sprite2D.new()
	var obj_image: ImageTexture = objects[sobj_index]
	obj_sprite.texture = obj_image
	obj_sprite.centered = false
	obj_sprite.position.x = location.x * Resources.tile_size
	obj_sprite.offset.y = -(sobj_height) * Resources.tile_size
	obj_sprite.position.y = ((location.y - sobj_height + 1) * Resources.tile_size) - obj_sprite.offset.y
	obj_sprite.y_sort_enabled = true
	obj_sprite.z_index = 1
	obj_sprite.z_as_relative = false

	parent.objects.add_child(obj_sprite)

func create_objects(parent: Node2D, map_id: int, x: int, y: int, width: int, height: int) -> void:
	clear_objects(parent.objects)
	var map_area := Rect2i(x, y, width, height)
	var start_i: int = max(0, (y * cmp.width) + (x % cmp.width))
	var end_i: int = min(len(cmp.tiles), ((y + height) * cmp.width) + ((x + cmp.width) % cmp.width))
	for i in range(start_i, end_i):
		var tile_position := Vector2i((i % cmp.width), (i / cmp.width))
		if not map_area.has_point(tile_position):
			continue
		var sobj_index := cmp.tiles[i].sobj_index
		if sobj_index < 1:
			continue
		var sobj: SObj = sobj_renderer.sobj.objects[sobj_index]
		var sobj_height := sobj.height
		if sobj_height < 1:
			continue
		create_object(parent, sobj_index, tile_position)
	
	# Overlays
	if String.num(map_id) in NTK_Maps.Overlays:
		for overlay in NTK_Maps.Overlays[String.num(map_id)]:
			if 'sobj_index' in overlay:
				create_object(parent, overlay.sobj_index, overlay.location)
