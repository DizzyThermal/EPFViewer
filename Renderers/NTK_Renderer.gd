class_name NTK_Renderer extends Node

const Indices = preload("res://DataTypes/Indices.gd")
const NTK_Frame = preload("res://DataTypes/NTK_Frame.gd")
const Palette = preload("res://DataTypes/Palette.gd")

var epfs: Array[EpfFileHandler] = []
var pal: PalFileHandler = null

var images := {}

func create_pixel_data(
		frame_index: int,
		palette_index: int,
		animated_color_offset: int=0,
		initial_color_offset: int=0,
		offset_range: Array[int]=[]) -> PackedByteArray:
	var frame := get_frame(frame_index)
	var palette := pal.get_palette(palette_index)
	var pixel_data := PackedByteArray()
	pixel_data.resize(frame.width * frame.height * 4)
	
	for i in range(frame.width * frame.height):
		var original_color_index := frame.raw_pixel_data.decode_u8(i)
		var color_index := (original_color_index + initial_color_offset) % Resources.palette_color_count
		if len(offset_range) > 0 and original_color_index not in offset_range:
			color_index = original_color_index

		for animation_range in palette.animation_ranges:
			var animated_colors := []
			var min_index = animation_range.min_index
			var max_index = animation_range.max_index
			animated_colors.append_array(range(min_index, max_index+1))

			if color_index in animated_colors:
				var animated_colors_index := (animated_colors.find(original_color_index) + animated_color_offset) % len(animated_colors)
				color_index = animated_colors[animated_colors_index]
				break

		var color := palette.colors[color_index]
		pixel_data.encode_u32((i * 4), color.to_abgr32())

	return pixel_data

func get_frame(frame_index: int, read_stencil=true) -> NTK_Frame:
	var indices := Indices.new(frame_index, epfs)
	return epfs[indices.epf_index].get_frame(indices.frame_index, read_stencil, frame_index)

func render_frame(
		frame_index: int,
		palette_index: int=0,
		read_stencil: bool=true,
		animated_color_offset: int=0,
		initial_color_offset: int=0,
		render_animated: bool=false,
		offset_range: Array[int]=[]) -> Image:
	var image_key := String.num(frame_index) + "-" + String.num(palette_index) + "-" + String.num(animated_color_offset) 
	if image_key in images:
		return images[image_key]

	var frame := get_frame(frame_index, read_stencil)
	var pixel_data := create_pixel_data(frame_index, palette_index, animated_color_offset, initial_color_offset, offset_range)
	var frame_image := Image.create_from_data(frame.width, frame.height, false, Image.FORMAT_RGBA8, pixel_data)
	if frame.mask_image and read_stencil:
		var image := Image.create(frame.width, frame.height, false, Image.FORMAT_RGBA8)
		var mask_rect := Rect2i(0, 0, frame.mask_image.get_width(), frame.mask_image.get_height())
		image.blit_rect_mask(frame_image, frame.mask_image, mask_rect, Vector2i(0, 0))
		images[image_key] = image
	else:
		images[image_key] = frame_image

	return images[image_key]

func render_animated_frame(
		frame_index: int,
		animation_count: int,
		palette_index: int=0,
		read_stencil: bool=true,
		color_offset: int=0) -> Image:
	var frame := get_frame(frame_index, read_stencil)
	var animated_spritesheet := Image.create(frame.width * animation_count, frame.height, false, Image.FORMAT_RGBA8)
	for i in range(animation_count):
		animated_spritesheet.blit_rect(
			render_frame(frame_index, palette_index, read_stencil, -i),
			Rect2i(0, 0, frame.width, frame.height),
			Vector2i(i * frame.width, 0))

	return animated_spritesheet

func create_animation_spritesheet(
		frame_indices: Array[int],
		palette_index=-1) -> Image:
	var start_time := Time.get_ticks_msec()
	var frames: Array[NTK_Frame] = []
	var images := []
	for frame_index in frame_indices:
		frames.append(get_frame(frame_index))
		images.append(render_frame(frame_index, palette_index))

	var pivot := Pivot.get_pivot(frames)

	var sprite_sheet := Image.create(pivot.width * len(images), pivot.height, false, Image.FORMAT_RGBA8)
	for offset in range(len(images)):
		var image: Image = images[offset]
		var frame: NTK_Frame = frames[offset]
		var frame_pivot = Pivot.get_pivot([frame])
		var image_rect := Rect2i(0, 0, frame.width, frame.height)
		var left = frame_pivot.x + abs(pivot.x)
		var top = frame_pivot.y + abs(pivot.y)
		var image_dst := Vector2i((pivot.width * offset) + left, top)
		sprite_sheet.blit_rect(image, image_rect, image_dst)

	return sprite_sheet

static func get_image_from_dat(
		epf_dat_name: String,
		epf_name: String,
		pal_dat_name: String,
		pal_name: String,
		frame_index: int=0,
		palette_index: int=0) -> Image:
	var epf_dat := DatFileHandler.new(epf_dat_name)
	var pal_dat := DatFileHandler.new(pal_dat_name)

	return get_image_with_dats(epf_dat, epf_name, pal_dat, pal_name, frame_index, palette_index)

static func get_image_with_dats(
		epf_dat: DatFileHandler,
		epf_name: String,
		pal_dat: DatFileHandler,
		pal_name: String,
		frame_index: int=0,
		palette_index: int=0,
		color_offset: int=0) -> Image:
	var renderer := NTK_Renderer.new()
	renderer.epfs.append(EpfFileHandler.new(epf_dat.get_file(epf_name)))
	renderer.pal = PalFileHandler.new(pal_dat.get_file(pal_name))

	return renderer.render_frame(frame_index, palette_index, true, color_offset)

static func get_image_with_file_handlers(
		epf_dat: DatFileHandler,
		epf: EpfFileHandler,
		pal_dat: DatFileHandler,
		pal: PalFileHandler,
		frame_index: int=0,
		palette_index: int=0,
		animated_color_offset: int=0,
		initial_color_offset: int=0,
		render_animated: bool=false,
		offset_range: Array[int]=[]) -> Image:
	var renderer := NTK_Renderer.new()
	renderer.epfs.append(epf)
	renderer.pal = pal

	return renderer.render_frame(frame_index, palette_index, true, animated_color_offset, initial_color_offset, render_animated, offset_range)
