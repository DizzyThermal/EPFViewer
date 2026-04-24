class_name FrameCacheItem extends Node

var index_texture: ImageTexture
var frame_shader: ShaderMaterial

func _init(
		frame_index_texture: ImageTexture,
		frame_frame_shader: ShaderMaterial) -> void:
	self.index_texture = frame_index_texture
	self.frame_shader = frame_frame_shader
