class_name NTK_Renderer extends Node

var epfs: Array[EpfFileHandler] = []
var pal: PalFileHandler = null

func get_frame(frame_index: int) -> NTK_Frame:
	var indices := Indices.new(frame_index, epfs)
	return epfs[indices.epf_index].get_frame(indices.frame_index, frame_index)

static func get_frame_from_dat(
		epf_dat_name: String,
		epf_name: String,
		frame_index: int=0) -> NTK_Frame:
	var epf_dat := DatFileHandler.new(epf_dat_name)
	var renderer := NTK_Renderer.new()
	renderer.epfs.append(EpfFileHandler.new(epf_dat.get_file(epf_name)))

	return renderer.get_frame(frame_index)

static func get_frame_sprite_from_dat(
		epf_dat_name: String,
		epf_name: String,
		pal_dat_name: String,
		pal_name: String,
		frame_index: int=0,
		palette_index: int=0) -> FrameSprite:
	var epf_dat := DatFileHandler.new(epf_dat_name)
	var pal_dat := DatFileHandler.new(pal_dat_name)

	return get_frame_sprite_with_dats(epf_dat, epf_name, pal_dat, pal_name, frame_index, palette_index)

static func get_frame_sprite_with_dats(
		epf_dat: DatFileHandler,
		epf_name: String,
		pal_dat: DatFileHandler,
		pal_name: String,
		frame_index: int=0,
		palette_index: int=0,
		color_offset: int=0) -> FrameSprite:
	# Instantiate a Renderer
	var renderer := NTK_Renderer.new()
	renderer.epfs.append(EpfFileHandler.new(epf_dat.get_file(epf_name)))
	renderer.pal = PalFileHandler.new(pal_dat.get_file(pal_name))

	# Create FrameSprite
	var frame: NTK_Frame = renderer.get_frame(frame_index)
	var palette: Palette = renderer.pal.get_palette(palette_index)
	var frame_key: String = "-".join([epf_name, pal_name, frame_index, palette_index])
	var frame_sprite: FrameSprite = FrameSprite.new(frame_key, frame, palette, color_offset)
	frame_sprite.set_meta("frame_index", frame_index)
	frame_sprite.set_meta("palette_index", palette_index)

	return frame_sprite

static func get_frame_texture_rect_from_dat(
		epf_dat_name: String,
		epf_name: String,
		pal_dat_name: String,
		pal_name: String,
		frame_index: int=0,
		palette_index: int=0) -> FrameTextureRect:
	var epf_dat := DatFileHandler.new(epf_dat_name)
	var pal_dat := DatFileHandler.new(pal_dat_name)

	return get_frame_texture_rect_with_dats(epf_dat, epf_name, pal_dat, pal_name, frame_index, palette_index)

static func get_frame_texture_rect_with_dats(
		epf_dat: DatFileHandler,
		epf_name: String,
		pal_dat: DatFileHandler,
		pal_name: String,
		frame_index: int=0,
		palette_index: int=0,
		color_offset: int=0) -> FrameTextureRect:
	# Instantiate a Renderer
	var renderer := NTK_Renderer.new()
	renderer.epfs.append(EpfFileHandler.new(epf_dat.get_file(epf_name)))
	renderer.pal = PalFileHandler.new(pal_dat.get_file(pal_name))

	# Create FrameTextureRect
	var frame: NTK_Frame = renderer.get_frame(frame_index)
	var palette: Palette = renderer.pal.get_palette(palette_index)
	var frame_key: String = "-".join([epf_name, pal_name, frame_index, palette_index])
	var frame_texture_rect: FrameTextureRect = FrameTextureRect.new(frame_key, frame, palette, color_offset)
	frame_texture_rect.set_meta("frame_index", frame_index)
	frame_texture_rect.set_meta("palette_index", palette_index)

	return frame_texture_rect

static func create_index_texture(frame: NTK_Frame) -> ImageTexture:
	var pixel_count: int = frame.width * frame.height
	var bytes := PackedByteArray()
	bytes.resize(pixel_count * 4)

	for pixel in range(pixel_count):
		var idx := pixel * 4
		bytes[idx] = frame.raw_pixel_data[pixel]
		bytes[idx + 1] = 0
		bytes[idx + 2] = 0
		bytes[idx + 3] = 255

	return ImageTexture.create_from_image(
		Image.create_from_data(
			frame.width,
			frame.height,
			false,
			Image.FORMAT_RGBA8,
			bytes
		)
	)

static func create_palette_texture(palette: Palette) -> ImageTexture:
	var bytes := PackedByteArray()
	bytes.resize(Resources.palette_color_count * 4)

	for i in range(Resources.palette_color_count):
		var c: Color = palette.colors[i]
		var idx := i * 4
		bytes[idx] = c.r8
		bytes[idx + 1] = c.g8
		bytes[idx + 2] = c.b8
		bytes[idx + 3] = 255

	return ImageTexture.create_from_image(
		Image.create_from_data(
			Resources.palette_color_count,
			1,
			false,
			Image.FORMAT_RGBA8,
			bytes
		)
	)

# Shaderless Rendering (SLOW)
func create_pixel_data(
		frame_index: int,
		palette_index: int,
		animated_color_offset: int=0,
		initial_color_offset: int=0) -> PackedByteArray:
	var frame := get_frame(frame_index)
	var palette := pal.get_palette(palette_index)
	var pixel_count := frame.width * frame.height
	var pixel_data := PackedByteArray()
	pixel_data.resize(pixel_count * 4)

	var color_map = PackedInt32Array()
	color_map.resize(Resources.palette_color_count)

	for i in range(Resources.palette_color_count):
		var original_idx = i
		var current_idx = i

		if len(Resources.offset_range) == 0 or original_idx in Resources.offset_range:
			current_idx = (original_idx + initial_color_offset) % Resources.palette_color_count

		for anim in palette.animation_ranges:
			if current_idx >= anim.min_index and current_idx <= anim.max_index:
				var range_len = anim.max_index - anim.min_index + 1
				var current_pos = current_idx - anim.min_index
				var shifted_pos = posmod(current_pos + animated_color_offset, range_len)
				current_idx = anim.min_index + shifted_pos
				break

		color_map[i] = current_idx

	var raw = frame.raw_pixel_data
	var palette_colors = palette.colors

	for i in range(pixel_count):
		var raw_idx = raw[i]
		var mapped_idx = color_map[raw_idx]
		var color_u32 = palette_colors[mapped_idx].to_abgr32()
		pixel_data.encode_u32(i * 4, color_u32)

	return pixel_data

# Shaderless Rendering (SLOW)
func render_frame(
		frame_index: int,
		palette_index: int=0,
		animated_color_offset: int=0,
		initial_color_offset: int=0) -> Image:
	var frame := get_frame(frame_index)
	if frame.width == 0 or frame.height == 0:
		return null
	var pixel_data := create_pixel_data(frame_index, palette_index, animated_color_offset, initial_color_offset)
	var frame_image := Image.create_from_data(frame.width, frame.height, false, Image.FORMAT_RGBA8, pixel_data)
	if frame.mask_image != null \
			and frame.mask_image.get_width() > 0 \
			and frame.mask_image.get_height() > 0:
		var image := Image.create_empty(frame.width, frame.height, false, Image.FORMAT_RGBA8)
		var mask_rect := Rect2i(0, 0, frame.mask_image.get_width(), frame.mask_image.get_height())
		image.blit_rect_mask(frame_image, frame.mask_image, mask_rect, Vector2i(0, 0))
		frame_image = image

	return frame_image
