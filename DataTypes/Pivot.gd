class_name Pivot extends Node

var x: int
var y: int
var width: int
var height: int

func _init(
		p_x: int,
		p_y: int,
		p_width: int,
		p_height: int) -> void:
	self.x = p_x
	self.y = p_y
	self.width = p_width
	self.height = p_height

static func get_pivot(
		frames: Array[NTK_Frame],
		spread: bool=false) -> Pivot:
	var pivot_left: int = 1000000
	var pivot_top: int = 1000000
	var pivot_right: int = -1000000
	var pivot_bottom: int = -1000000
	for frame in frames:
		if frame.left < pivot_left:
			pivot_left = frame.left
		if frame.top < pivot_top:
			pivot_top = frame.top
		if frame.right > pivot_right:
			pivot_right = frame.right
		if frame.bottom > pivot_bottom:
			pivot_bottom = frame.bottom

	if spread:
		if abs(pivot_left) > abs(pivot_right):
			pivot_right = abs(pivot_left)
		else:
			pivot_left = pivot_right * -1
		if abs(pivot_top) > abs(pivot_bottom):
			pivot_bottom = abs(pivot_top)
		else:
			pivot_top = pivot_bottom * -1
	var pivot_width: int = pivot_right - pivot_left
	var pivot_height: int = pivot_bottom - pivot_top

	return Pivot.new(pivot_left, pivot_top, pivot_width, pivot_height)
