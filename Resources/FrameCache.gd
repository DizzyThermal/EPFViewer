extends Node

@onready var frame_cache: Dictionary[String, FrameCacheItem] = {}

func prune_cache(to_size: int) -> void:
	var num_to_remove: int = len(self.frame_cache) - to_size
	if num_to_remove > 0:
		var keys_to_remove: Array[String] = []
		for frame_key in self.frame_cache.keys():
			keys_to_remove.append(frame_key)
			if len(keys_to_remove) >= num_to_remove:
				break
		for frame_key in keys_to_remove:
			self.frame_cache.erase(frame_key)

func has_item(frame_key: String) -> bool:
	return frame_key in self.frame_cache

func add_item(
		frame_key: String,
		index_texture: ImageTexture,
		frame_shader: ShaderMaterial) -> void:
	self.frame_cache[frame_key] = FrameCacheItem.new(
			index_texture,
			frame_shader
	)

func get_item(frame_key: String) -> FrameCacheItem:
	var cache_item: FrameCacheItem

	if frame_key in self.frame_cache:
		cache_item = self.frame_cache[frame_key]

	return cache_item

func size() -> int:
	return len(self.frame_cache)
