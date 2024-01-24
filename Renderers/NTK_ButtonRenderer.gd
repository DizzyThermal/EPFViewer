class_name NTK_ButtonRenderer extends Node

const NTK_Frame = preload("res://DataTypes/NTK_Frame.gd")

var buttons := {}

func _init():
	var bint0_dat := DatFileHandler.new("bint0.dat")

	var button_renderer := NTK_Renderer.new()
	button_renderer.epfs.append(EpfFileHandler.new(bint0_dat.get_file("butt001.epf")))
	button_renderer.pal = PalFileHandler.new(bint0_dat.get_file("butt001.pal"))

	# Create Buttons
	buttons["Ok"] = create_button(14, button_renderer)
	buttons["Close"] = create_button(15, button_renderer)
	buttons["Up"] = create_button(16, button_renderer)
	buttons["Previous"] = create_button(18, button_renderer)
	buttons["Next"] = create_button(19, button_renderer)

func create_button(
		button_index: int,
		button_renderer: NTK_Renderer,
		button_frame_count: int=4) -> Dictionary:
	var button_start_index := button_index * button_frame_count
	var button_end_index := button_start_index + button_frame_count
	var button_images: Array[Image] = []
	for i in range(button_start_index, button_end_index):
		button_images.append(button_renderer.render_frame(i))

	return {
		"Normal": ImageTexture.create_from_image(button_images[0]),
		"Pressed": ImageTexture.create_from_image(button_images[1]),
		"Disabled": ImageTexture.create_from_image(button_images[2]),
		"Focused": ImageTexture.create_from_image(button_images[3]),
	}
