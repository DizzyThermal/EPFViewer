class_name Pivot extends Node

const NTK_Frame = preload("res://DataTypes/NTK_Frame.gd")

var x := 0
var y := 0
var width := 0
var height := 0

func _init(x: int, y: int, width: int, height: int):
	self.x = x
	self.y = y
	self.width = width
	self.height = height

static func get_pivot(
		frames: Array[NTK_Frame],
		spread: bool=false) -> Pivot:
	var pivot_left := 1000000
	var pivot_top := 1000000
	var pivot_right := -1000000
	var pivot_bottom := -1000000
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
	var pivot_width := pivot_right - pivot_left
	var pivot_height := pivot_bottom - pivot_top

	return Pivot.new(pivot_left, pivot_top, pivot_width, pivot_height)
