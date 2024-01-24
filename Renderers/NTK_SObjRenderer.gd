class_name NTK_SObjRenderer extends Node

const SObj = preload("res://DataTypes/SObj.gd")

var tilec_renderer: NTK_TileRenderer = null
var sobj: SObjTblFileHandler = null

var object_images := {}

func _init():
	var start_time := Time.get_ticks_msec()
	tilec_renderer = NTK_TileRenderer.new("tilec\\d+\\.dat", "TileC.pal", "TILEC.TBL")
	sobj = SObjTblFileHandler.new(DatFileHandler.new("tile.dat").get_file("SObj.tbl"))
	
	if Debug.debug_renderer_timings:
		print("[SObjRenderer]: ", Time.get_ticks_msec() - start_time, " ms")

func render_object(object_index: int) -> ImageTexture:
	if object_index not in object_images:
		var object: SObj = sobj.objects[object_index]
		var object_image := Image.create(Resources.tile_size, Resources.tile_size * object.height, false, Image.FORMAT_RGBA8)
		for i in range(object.height):
			var tile_index := object.tile_indices[i]
			var palette_index := tilec_renderer.tbl.palette_indices[tile_index]
			var image_key := String.num(tile_index) + "-" + String.num(palette_index)
			var frame := tilec_renderer.get_frame(object.tile_indices[i])
			var frame_rect := Rect2i(0, 0, frame.width, frame.height)
			object_image.blit_rect_mask(
				tilec_renderer.render_frame(object.tile_indices[i], palette_index), 
				frame.mask_image,
				frame_rect,
				Vector2i(frame.left, (object.height - i - 1) * Resources.tile_size + frame.top))
			object_images[object_index] = object_image

	return ImageTexture.create_from_image(object_images[object_index])
