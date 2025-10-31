class_name NTK_CharacterRenderer extends Node

const NTK_Frame = preload("res://DataTypes/NTK_Frame.gd")
const NTK_PartRenderer = preload("res://Renderers/NTK_PartRenderer.gd")

var arrow_renderer: NTK_PartRenderer = null
var body_renderer: NTK_PartRenderer = null
var coat_renderer: NTK_PartRenderer = null
var mantle_renderer: NTK_PartRenderer = null
var face_renderer: NTK_PartRenderer = null
var face_dec_renderer: NTK_PartRenderer = null
var helmet_renderer: NTK_PartRenderer = null
var hair_renderer: NTK_PartRenderer = null
var hair_dec_renderer: NTK_PartRenderer = null
var necklace_renderer: NTK_PartRenderer = null
var bow_renderer: NTK_PartRenderer = null
var spear_renderer: NTK_PartRenderer = null
var sword_renderer: NTK_PartRenderer = null
var shield_renderer: NTK_PartRenderer = null
var shoes_renderer: NTK_PartRenderer = null

var renderer_threads: Array[Thread] = []
var part_renderers := {}

var character_frames: Array[NTK_Frame] = []
var character_pivot: Pivot

func _init() -> void:
	var start_time := Time.get_ticks_msec()

	# Create Renderers (Threaded)
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.arrow_renderer = NTK_PartRenderer.new("Arrow", Renderers.char_dat, Renderers.misc_dat))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.body_renderer = NTK_PartRenderer.new("Body", Renderers.char_dat, Renderers.misc_dat))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.coat_renderer = NTK_PartRenderer.new("Coat", Renderers.char_dat, Renderers.misc_dat))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.mantle_renderer = NTK_PartRenderer.new("Mantle", Renderers.char_dat, Renderers.misc_dat))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.face_renderer = NTK_PartRenderer.new("Face", Renderers.char_dat, Renderers.misc_dat))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.face_dec_renderer = NTK_PartRenderer.new("FaceDec", Renderers.char_dat , Renderers.misc_dat, "FaceDec"))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.helmet_renderer = NTK_PartRenderer.new("Helmet", Renderers.char_dat, Renderers.misc_dat))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.hair_renderer = NTK_PartRenderer.new("Hair", Renderers.char_dat, Renderers.misc_dat))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.hair_dec_renderer = NTK_PartRenderer.new("HairDec", Renderers.char_dat, Renderers.misc_dat, "HairDec"))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.necklace_renderer = NTK_PartRenderer.new("Neck", Renderers.char_dat, Renderers.misc_dat, "Neck"))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.bow_renderer = NTK_PartRenderer.new("Bow", Renderers.char_dat, Renderers.misc_dat))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.spear_renderer = NTK_PartRenderer.new("Spear", Renderers.char_dat, Renderers.misc_dat))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.sword_renderer = NTK_PartRenderer.new("Sword", Renderers.char_dat, Renderers.misc_dat))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.shield_renderer = NTK_PartRenderer.new("Shield", Renderers.char_dat, Renderers.misc_dat))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.shoes_renderer = NTK_PartRenderer.new("Shoes", Renderers.char_dat, Renderers.misc_dat))

	# Wait for all renderer threads to finish
	var all_finished := false
	while not all_finished:
		all_finished = true
		for renderer_thread in renderer_threads:
			if renderer_thread.is_alive():
				all_finished = false
				break
	for thread in renderer_threads:
		thread.wait_to_finish()

	part_renderers["Body"] = body_renderer
	part_renderers["Mantle"] = mantle_renderer
	part_renderers["Face"] = face_renderer
	part_renderers["FaceDec"] = face_dec_renderer
	part_renderers["Helmet"] = helmet_renderer
	part_renderers["Hair"] = hair_renderer
	part_renderers["HairDec"] = hair_dec_renderer
	part_renderers["Necklace"] = necklace_renderer
	part_renderers["Bow"] = bow_renderer
	part_renderers["Spear"] = spear_renderer
	part_renderers["Sword"] = sword_renderer
	part_renderers["Shield"] = shield_renderer
	part_renderers["Shoes"] = shoes_renderer
	
	if Debug.debug_renderer_timings:
		print("[CharacterRenderer]: ", Time.get_ticks_msec() - start_time, " ms")

func render_part(
	motion_id: int,
	motion_frame_index: int,
	palette_animation_last_tick: int,
	part_layer_id: NTK_Animations.PartLayer,
	part_name: String,
	part_info: Dictionary) -> Sprite2D:
	var motion: Motion = Renderers.motion_tbl.motions[motion_id]
	var part_renderer: NTK_PartRenderer = part_renderers[part_name]
	var part: Part = part_renderer.dsc.parts[part_info.item.char_index]
	## TODO: Incorporate chunkNumber w/ animations Dictionary
	## Old Idx (Band-Aid): NTK_Animations.PartAnimations[motion.motion_name][part_name]
	var part_animation: PartAnimation = part.animations[motion_id]
	##
	var part_animation_frame: PartAnimationFrames = part_animation.animation_frames[motion_frame_index]
	var frame_index: int = part.frame_index + part_animation_frame.frame_offset
	var part_frame: NTK_Frame = part_renderer.get_frame(frame_index)
	character_frames.append(part_frame)
	var part_image: Image = part_renderer.render_frame(
		frame_index,
		part_info.item.char_palette if 'char_palette' in part_info.item else 0,
		palette_animation_last_tick,
		part_info.item.char_color_offset if 'char_color_offset' in part_info.item else 0)
	var part_sprite = Sprite2D.new()
	part_sprite.centered = false
	part_sprite.texture = ImageTexture.create_from_image(part_image)
	part_sprite.position.x = part_frame.left
	part_sprite.position.y = part_frame.top

	return part_sprite

func render_character(
		motion_id: int,
		motion_frame_index: int,
		palette_animation_last_tick: int,
		parts: Dictionary) -> Array:
	character_frames.clear()
	var character_sprites: Array[Sprite2D] = []

	var motion: Motion = Renderers.motion_tbl.motions[motion_id]
	var motion_frame: MotionFrame = motion.motion_frames[motion_frame_index]
	for part_layer_id in motion_frame.part_layer_ids:
		var part_name: String = NTK_Animations.PartLayerIds[part_layer_id]
		if part_layer_id == NTK_Animations.PartLayer.MainWeapon:
			if len(parts["Sword"]) > 0:
				part_name = "Sword"
			elif len(parts["Spear"]) > 0:
				part_name = "Spear"
			elif len(parts["Bow"]) > 0:
				part_name = "Bow"
		if part_name not in part_renderers or part_name not in parts or len(parts[part_name]) == 0:
			continue
		var part_sprite := render_part(motion_id, motion_frame_index, palette_animation_last_tick, part_layer_id, part_name, parts[part_name])
		if part_sprite != null:
			character_sprites.append(part_sprite)

	character_pivot = Pivot.get_pivot(character_frames)
	return [character_pivot, character_sprites]
