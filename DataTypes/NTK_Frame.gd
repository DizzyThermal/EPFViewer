extends Node

var left: int = 0
var top: int = 0
var right: int = 0
var bottom: int = 0
var width: int = 0
var height: int = 0
var size: Vector2i = Vector2i(0, 0)
var raw_pixel_data := PackedByteArray()
var raw_pixel_data_array: Array[int] = []
var mask_image: Image = null

func _init(left: int, top: int, right: int, bottom: int, width: int, height: int, raw_pixel_data: PackedByteArray, mask_image: Image):
	self.left = left
	self.top = top
	self.right = right
	self.bottom = bottom
	self.width = width
	self.height = height
	self.size = Vector2i(width, height)
	self.raw_pixel_data.append_array(raw_pixel_data)
	self.raw_pixel_data_array.append_array(Array(self.raw_pixel_data))
	self.mask_image = mask_image
