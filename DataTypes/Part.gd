class_name Part extends Node

const PartAnimation = preload("res://DataTypes/PartAnimation.gd")

var id := -1
var palette_index := -1
var frame_index := -1
var frame_count := -1
var unknown_bytes := PackedByteArray()
var animations: Array[PartAnimation] = []

func _init(
		id: int,
		palette_index: int,
		frame_index: int,
		frame_count: int,
		unknown_bytes: PackedByteArray,
		animations: Array[PartAnimation]):
	self.id = id
	self.palette_index = palette_index
	self.frame_index = frame_index
	self.frame_count = frame_count
	self.unknown_bytes.append_array(unknown_bytes)
	self.animations.append_array(animations)
