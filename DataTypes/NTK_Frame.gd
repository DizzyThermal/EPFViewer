class_name NTK_Frame extends Node

var left: int
var top: int
var right: int
var bottom: int
var width: int
var height: int
var size: Vector2i = Vector2i(0, 0)
var pivot: Vector2i = Vector2i(0, 0)
var raw_pixel_data: PackedByteArray = PackedByteArray()
var raw_pixel_data_array: Array[int] = []
var mask_image: Image

func _init(
		p_left: int,
		p_top: int,
		p_right: int,
		p_bottom: int,
		p_width: int,
		p_height: int,
		p_raw_pixel_data: PackedByteArray,
		p_mask_image: Image):
	self.left = p_left
	self.top = p_top
	self.right = p_right
	self.bottom = p_bottom
	self.width = p_width
	self.height = p_height
	self.size = Vector2i(self.width, self.height)
	self.pivot = Vector2i(self.left, self.top)
	self.raw_pixel_data.append_array(p_raw_pixel_data)
	self.raw_pixel_data_array.append_array(Array(self.raw_pixel_data))
	self.mask_image = p_mask_image
