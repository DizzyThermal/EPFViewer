class_name Mob extends Node

const MobAnimation = preload("res://DataTypes/MobAnimation.gd")

var frame_index := -1
var animation_count := -1
var unknown_byte := -1
var palette_index := -1
var animations: Array[MobAnimation] = []

func _init(
		frame_index: int,
		animation_count: int,
		unknown_byte: int,
		palette_index: int,
		animations: Array[MobAnimation]):
	self.frame_index = frame_index
	self.animation_count = animation_count
	self.unknown_byte = unknown_byte
	self.palette_index = palette_index
	self.animations.append_array(animations)
