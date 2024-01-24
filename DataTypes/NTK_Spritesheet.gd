class_name NTK_Spritesheet extends Node

var sprite_sheet: Image = null
var frame_canvas_left := 0
var frame_canvas_top := 0

func _init(
		sprite_sheet: Image,
		frame_canvas_left: int,
		frame_canvas_top: int) -> void:
	self.sprite_sheet = sprite_sheet
	self.frame_canvas_left = frame_canvas_left
	self.frame_canvas_top = frame_canvas_top
