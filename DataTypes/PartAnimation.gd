class_name PartAnimation extends Node

const PartAnimationFrame = preload("res://DataTypes/PartAnimationFrame.gd")

var animation_index := -1
var unknown_bytes := PackedByteArray()
var animation_frames: Array[PartAnimationFrame] = []

func _init(
		animation_index: int,
		unknown_bytes: PackedByteArray,
		animation_frames: Array[PartAnimationFrame]):
	self.animation_index = animation_index
	self.unknown_bytes.append_array(unknown_bytes)
	self.animation_frames.append_array(animation_frames)
