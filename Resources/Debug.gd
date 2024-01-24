extends Node

## Debug ##
var debug_renderer_timings := true

# 0 | Body0.epf Frame 0
var debug_frame_indices: Array[int] = []
var debug_show_pixel_data := false

## Tile Debug ##
# Vector2i(14, 121) | Tangun (Animated Tile) => AB Index 31123
var debug_tile_coords: Array[Vector2i] = []
# 31123 | Tangun - Animated AB Tile (14, 121)
var debug_tile_indices: Array[int] = []

## Palette Debug ##
# 187 | AB Index 31123 PAL => 187
var debug_pal_indices: Array[int] = []

## Part Debug ##
# i.e., {"Body": 55} - SetZe Robes
var debug_parts := {}
# i.e., {"Body": 0} - Frame[0] (Local Frame Offset (in loop))
var debug_part_frames := {}
# i.e., {"Body": 0} DSC Part Number
var debug_part_dsc := {}

## Mob Debug ##
var debug_mob_indices: Array[int] = []

## Map Debug ##
# Saves PNG of rendered TileMap if true
var debug_map_tilemap = false

# Save Image to Desktop
func save_png_to_desktop(image: Image, image_name: String="test.png", sub_directory: String="") -> void:
	var desktop_dir := ""
	if OS.get_name() == "Windows":
		desktop_dir = OS.get_environment("USERPROFILE") + "/Desktop/" + sub_directory
	else:
		desktop_dir = OS.get_environment("HOME") + "/Desktop/" + sub_directory

	if not image_name.ends_with(".png"):
		image_name = image_name + ".png"
	if sub_directory and not sub_directory.begins_with("/"):
		sub_directory = "/" + sub_directory
	image.save_png(desktop_dir + "/" + image_name)
	print("Saved PNG to ./Desktop", sub_directory, "/", image_name)
