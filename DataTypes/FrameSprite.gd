class_name FrameSprite extends Sprite2D

var is_animated: bool = false
var animation_length: int = 0
var palette_animation_last_tick: int = 0

var frame_key: String
var ntk_frame: NTK_Frame
var palette: Palette
var color_offset: int

func _init(
		p_frame_key: String,
		p_frame: NTK_Frame,
		p_palette: Palette,
		p_color_offset: int=0) -> void:
	# Frame Parameters
	self.frame_key = p_frame_key
	self.ntk_frame = p_frame
	self.palette = p_palette
	self.color_offset = p_color_offset
	self.centered = false
	self.offset = self.ntk_frame.pivot

	# Frame Initialization
	if not FrameCache.has_item(self.frame_key):
		if self.ntk_frame.width > 0 and self.ntk_frame.height > 0:
			var palette_animation_count: int = min(16, len(self.palette.animation_ranges))
			var index_texture: ImageTexture = NTK_Renderer.create_index_texture(self.ntk_frame)
			var mask_texture: ImageTexture = ImageTexture.create_from_image(self.ntk_frame.mask_image) if self.ntk_frame.mask_image != null else null
			var palette_texture: ImageTexture = NTK_Renderer.create_palette_texture(self.palette)
			var shader_material: ShaderMaterial = ShaderMaterial.new()
			var frame_shader: Shader = load("res://Shaders/NTK_FrameShader.gdshader")
			shader_material.shader = frame_shader
			shader_material.set_shader_parameter("mask_tex", mask_texture)
			shader_material.set_shader_parameter("palette_tex", palette_texture)
			shader_material.set_shader_parameter("animation_range_count", palette_animation_count)
			shader_material.set_shader_parameter("initial_color_offset", self.color_offset)
			var ranges: Array[Vector4i] = []
			for anim_idx in range(palette_animation_count):
				var r = palette.animation_ranges[anim_idx]
				ranges.append(Vector4i(r.min_index, r.max_index, 0, 0))
			shader_material.set_shader_parameter("animation_ranges", ranges)
			FrameCache.add_item(
				self.frame_key,
				index_texture,
				shader_material
			)

	if FrameCache.has_item(frame_key):
		if self.palette.is_animated:
			var frame_raw_pixel_data: Array[int] = self.ntk_frame.raw_pixel_data_array
			if Resources.arrays_intersect(self.palette.animation_indices, frame_raw_pixel_data):
				self.is_animated = true
				self.animation_length = self.palette.animation_length

		var cache_item: FrameCacheItem = FrameCache.get_item(self.frame_key)
		self.texture = cache_item.index_texture
		self.material = cache_item.frame_shader
