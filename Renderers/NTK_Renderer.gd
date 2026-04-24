class_name NTK_Renderer extends Node

const Indices = preload("res://DataTypes/Indices.gd")
const NTK_Frame = preload("res://DataTypes/NTK_Frame.gd")
const Palette = preload("res://DataTypes/Palette.gd")

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
