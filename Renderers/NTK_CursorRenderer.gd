class_name NTK_CursorRenderer extends Node

const NTK_Frame = preload("res://DataTypes/NTK_Frame.gd")

var cursors := {}

func _init():
	var bint0_dat := DatFileHandler.new("bint0.dat")

	var cursor_renderer := NTK_Renderer.new()
	cursor_renderer.epfs.append(EpfFileHandler.new(bint0_dat.get_file("CURSOR02.epf")))
	cursor_renderer.pal = PalFileHandler.new(bint0_dat.get_file("CURSOR02.pal"))

	# Create Cursors
	cursors["Idle"] = create_cursor(0, cursor_renderer)
	cursors["Select"] = create_cursor(1, cursor_renderer)
	cursors["Inspect"] = create_cursor(2, cursor_renderer)
	cursors["Grab"] = create_cursor(3, cursor_renderer)
	cursors["Attack"] = create_cursor(4, cursor_renderer)

func create_cursor(
		cursor_index: int,
		cursor_renderer: NTK_Renderer,
		cursor_frame_count: int=9) -> AnimatedTexture:
	var cursor_start_index := cursor_index * cursor_frame_count
	var cursor_end_index := cursor_start_index + cursor_frame_count
	var cursor_frames: Array[NTK_Frame] = []
	var cursor_frame_indices: Array[int] = []
	for i in range(cursor_start_index, cursor_end_index):
		cursor_frames.append(cursor_renderer.get_frame(i))
		cursor_frame_indices.append(i)
	var cursor_pivot := Pivot.get_pivot(cursor_frames)
	var cursor_spritesheet := cursor_renderer.create_animation_spritesheet(cursor_frame_indices)
	var cursor_texture := AnimatedTexture.new()
	cursor_texture.frames = 9
	for i in range(9):
		var region := Rect2i(cursor_pivot.width * i, 0, cursor_pivot.width, cursor_pivot.height)
		cursor_texture.set_frame_texture(i, ImageTexture.create_from_image(cursor_spritesheet.get_region(region)))
		cursor_texture.set_frame_duration(i, 0.15)

	return cursor_texture
