extends Node

var colors: Array[Color] = []

var animation_ranges := []
var animation_indices: Array[int] = []
var is_animated := false

var unknown_bytes_1: Array[int] = []
var unknown_bytes_2: Array[int] = []

func _init(
		colors: Array[Color],
		animation_ranges: Array,
		animation_indices: Array[int],
		unknown_bytes_1: Array[int],
		unknown_bytes_2: Array[int]):
	self.colors.append_array(colors)
	self.animation_ranges.append_array(animation_ranges)
	self.animation_indices.append_array(animation_indices)
	if self.animation_ranges:
		self.is_animated = true
	self.unknown_bytes_1.append_array(unknown_bytes_1)
	self.unknown_bytes_2.append_array(unknown_bytes_2)

func set_alpha(alpha) -> void:
	for i in range(Resources.palette_color_count):
		colors[i].a8 = alpha

func add_animated_range(
		min_index: int,
		max_index: int) -> void:
	self.animation_ranges.append({
		"min_index": min_index,
		"max_index": max_index,
	})
	self.animation_indices.append_array(range(min_index, max_index + 1))
	self.is_animated = true
