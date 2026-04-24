class_name FrameSprite extends Sprite2D

const NTK_Frame = preload("res://DataTypes/NTK_Frame.gd")
const Palette = preload("res://DataTypes/Palette.gd")

var is_animated: bool = false
var animation_length: int = 0
var palette_animation_last_tick: int = 0

func _init(
		frame_key: String,
		frame: NTK_Frame,
		palette: Palette,
		color_offset: int=0) -> void:
	# Frame Sprite2D Parameters
	self.centered = false
	self.offset = Vector2i(frame.left, frame.top)

	# Frame Initialization
	if not FrameCache.has_item(frame_key):
		if frame.width > 0 and frame.height > 0:
			var palette_animation_count: int = min(16, len(palette.animation_ranges))
			var index_texture: ImageTexture = NTK_Renderer.create_index_texture(frame)
			var mask_texture: ImageTexture = ImageTexture.create_from_image(frame.mask_image) if frame.mask_image != null else null
			var palette_texture: ImageTexture = NTK_Renderer.create_palette_texture(palette)
			var shader_material: ShaderMaterial = ShaderMaterial.new()
			var frame_shader: Shader = load("res://Shaders/NTK_FrameShader.gdshader")
			shader_material.shader = frame_shader
			shader_material.set_shader_parameter("mask_tex", mask_texture)
			shader_material.set_shader_parameter("palette_tex", palette_texture)
			shader_material.set_shader_parameter("animation_range_count", palette_animation_count)
			shader_material.set_shader_parameter("initial_color_offset", color_offset)
			var ranges: Array[Vector4i] = []
			for anim_idx in range(palette_animation_count):
				var r = palette.animation_ranges[anim_idx]
				ranges.append(Vector4i(r.min_index, r.max_index, 0, 0))
			shader_material.set_shader_parameter("animation_ranges", ranges)
			FrameCache.add_item(
				frame_key,
				index_texture,
				shader_material
			)

	if FrameCache.has_item(frame_key):
		if palette.is_animated:
			var frame_raw_pixel_data: Array[int] = frame.raw_pixel_data_array
			if Resources.arrays_intersect(palette.animation_indices, frame_raw_pixel_data):
				self.is_animated = true
				self.animation_length = palette.animation_length

		var cache_item: FrameCacheItem = FrameCache.get_item(frame_key)
		self.texture = cache_item.index_texture
		self.material = cache_item.frame_shader
