class_name NTK_ItemRenderer extends NTK_Renderer

var items := {}
var item_count := 0

func _init():
	var start_time := Time.get_ticks_msec()

	var misc_dat := DatFileHandler.new("misc.dat")

	pal = PalFileHandler.new(misc_dat.get_file("ITEM.PAL"))
	var epf := EpfFileHandler.new(misc_dat.get_file("ITEM.EPF"))
	item_count = epf.frame_count
	epfs.append(epf)

	if Debug.debug_renderer_timings:
		print("[ItemRenderer]: ", Time.get_ticks_msec() - start_time, " ms")

func create_item(
		item_index: int,
		palette_index: int=0) -> Sprite2D:
	var start_time := Time.get_ticks_msec()
	var image_key := String.num(item_index) + "-" + String.num(palette_index)
	if image_key not in items:
		items[image_key] = render_frame(item_index, palette_index)
	var item_image: ImageTexture = ImageTexture.create_from_image(items[image_key])

	var item_sprite := Sprite2D.new()
	item_sprite.texture = item_image

	if Debug.debug_renderer_timings:
		print("[Item]:      [", item_index, "-", palette_index, "]: ", Time.get_ticks_msec() - start_time, " ms\n")

	return item_sprite
