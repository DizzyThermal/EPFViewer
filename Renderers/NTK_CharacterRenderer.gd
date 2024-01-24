class_name NTK_CharacterRenderer extends Node

const NTK_Frame = preload("res://DataTypes/NTK_Frame.gd")
const NTK_PartRenderer = preload("res://Renderers/NTK_PartRenderer.gd")
const PartAnimation = preload("res://DataTypes/PartAnimation.gd")
const Pivot = preload("res://DataTypes/Pivot.gd")

var char_dat: DatFileHandler = null
var misc_dat: DatFileHandler = null

var body_renderer: NTK_PartRenderer = null
var mantle_renderer: NTK_PartRenderer = null
var face_renderer: NTK_PartRenderer = null
var face_dec_renderer: NTK_PartRenderer = null
var helmet_renderer: NTK_PartRenderer = null
var hair_renderer: NTK_PartRenderer = null
var hair_dec_renderer: NTK_PartRenderer = null
var necklace_renderer: NTK_PartRenderer = null
var spear_renderer: NTK_PartRenderer = null
var sword_renderer: NTK_PartRenderer = null
var shield_renderer: NTK_PartRenderer = null
var shoes_renderer: NTK_PartRenderer = null

var renderer_threads: Array[Thread] = []
var part_renderers: Array[NTK_PartRenderer] = []

var animation_frames := {}

func _init() -> void:
	var start_time := Time.get_ticks_msec()
	char_dat = DatFileHandler.new("char.dat")
	misc_dat = DatFileHandler.new("misc.dat")

	# Create Renderers (Threaded)
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.body_renderer = NTK_PartRenderer.new("Body", char_dat, misc_dat))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.mantle_renderer = NTK_PartRenderer.new("Mantle", char_dat, misc_dat))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.face_renderer = NTK_PartRenderer.new("Face", char_dat, misc_dat))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.face_dec_renderer = NTK_PartRenderer.new("FaceDec", char_dat , misc_dat, "FaceDec"))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.helmet_renderer = NTK_PartRenderer.new("Helmet", char_dat, misc_dat))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.hair_renderer = NTK_PartRenderer.new("Hair", char_dat, misc_dat))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.hair_dec_renderer = NTK_PartRenderer.new("HairDec", char_dat, misc_dat, "HairDec"))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.necklace_renderer = NTK_PartRenderer.new("Neck", char_dat, misc_dat, "Neck"))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.spear_renderer = NTK_PartRenderer.new("Spear", char_dat, misc_dat))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.sword_renderer = NTK_PartRenderer.new("Sword", char_dat, misc_dat))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.shield_renderer = NTK_PartRenderer.new("Shield", char_dat, misc_dat))
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.shoes_renderer = NTK_PartRenderer.new("Shoes", char_dat, misc_dat))

	# Wait for all renderer threads to finish
	var all_finished := false
	while not all_finished:
		all_finished = true
		for renderer_thread in renderer_threads:
			if renderer_thread.is_alive():
				all_finished = false
				break

	part_renderers.append(body_renderer)
	part_renderers.append(mantle_renderer)
	part_renderers.append(face_renderer)
	part_renderers.append(face_dec_renderer)
	part_renderers.append(helmet_renderer)
	part_renderers.append(hair_renderer)
	part_renderers.append(hair_dec_renderer)
	part_renderers.append(necklace_renderer)
	part_renderers.append(spear_renderer)
	part_renderers.append(sword_renderer)
	part_renderers.append(shield_renderer)
	part_renderers.append(shoes_renderer)
	
	if Debug.debug_renderer_timings:
		print("[CharacterRenderer]: ", Time.get_ticks_msec() - start_time, " ms")

func create_character(
		parent: Node2D,
		body: Dictionary={},
		mantle: Dictionary={},
		face: Dictionary={},
		face_dec: Dictionary={},
		helmet: Dictionary={},
		hair: Dictionary={},
		hair_dec: Dictionary={},
		necklace: Dictionary={},
		spear: Dictionary={},
		sword: Dictionary={},
		shield: Dictionary={},
		shoes: Dictionary={}) -> void:
	var start_time := Time.get_ticks_msec()

	if body:
		body_renderer.current_part = body.char_index
		body_renderer.current_palette = body.char_palette if 'char_palette' in body else -1
	else:
		body_renderer.current_part = 0
		body_renderer.current_palette = 0

	if mantle:
		mantle_renderer.current_part = mantle.char_index
		mantle_renderer.current_palette = mantle.char_palette if 'char_palette' in mantle else -1
	else:
		mantle_renderer.current_part = -1
		mantle_renderer.current_palette = -1

	if face:
		face_renderer.current_part = face.char_index
		face_renderer.current_palette = face.char_palette if 'char_palette' in face else -1
	else:
		face_renderer.current_part = 0
		face_renderer.current_palette = -1

	if face_dec:
		face_dec_renderer.current_part = face_dec.char_index
		face_dec_renderer.current_palette = face_dec.char_palette if 'char_palette' in face_dec else -1
	else:
		face_dec_renderer.current_part = -1
		face_dec_renderer.current_palette = -1

	if hair:
		hair_renderer.current_part = hair.char_index
		hair_renderer.current_palette = hair.char_palette if 'char_palette' in hair else -1
	else:
		hair_renderer.current_part = -1
		hair_renderer.current_palette = -1

	if hair_dec:
		hair_dec_renderer.current_part = hair_dec.char_index
		hair_dec_renderer.current_palette = hair_dec.char_palette if 'char_palette' in hair_dec else -1
	else:
		hair_dec_renderer.current_part = -1
		hair_dec_renderer.current_palette = -1

	if necklace:
		necklace_renderer.current_part = necklace.char_index
		necklace_renderer.current_palette = necklace.char_palette if 'char_palette' in necklace else -1
	else:
		mantle_renderer.current_part = -1
		mantle_renderer.current_palette = -1

	# Weapon
	if spear:
		spear_renderer.current_part = spear.char_index
		spear_renderer.current_palette = spear.char_palette if 'char_palette' in spear else -1
		sword_renderer.current_part = -1
		sword_renderer.current_palette = -1
	elif sword:
		sword_renderer.current_part = sword.char_index
		sword_renderer.current_palette = sword.char_palette if 'char_palette' in sword else -1
		spear_renderer.current_part = -1
		spear_renderer.current_palette = -1
	else:
		spear_renderer.current_part = -1
		spear_renderer.current_palette = -1
		sword_renderer.current_part = -1
		sword_renderer.current_palette = -1

	if shield:
		shield_renderer.current_part = shield.char_index
		shield_renderer.current_palette = shield.char_palette if 'char_palette' in shield else -1
	else:
		shield_renderer.current_part = -1
		shield_renderer.current_palette = -1

	if shoes:
		shoes_renderer.current_part = shoes.char_index
		shoes_renderer.current_palette = shoes.char_palette if 'char_palette' in shoes else -1
	else:
		shoes_renderer.current_part = -1
		shoes_renderer.current_palette = -1

	parent.character.remove_part_sprites()

	var canvas_pivot := Pivot.get_pivot(get_all_frames(), true)

	create_part_sprites(parent, body_renderer, canvas_pivot)
	create_part_sprites(parent, face_renderer, canvas_pivot)
	if mantle:
		create_part_sprites(parent, mantle_renderer, canvas_pivot)
	if face_dec:
		create_part_sprites(parent, face_dec_renderer, canvas_pivot)
	if hair_dec:
		create_part_sprites(parent, hair_dec_renderer, canvas_pivot)
	if hair:
		create_part_sprites(parent, hair_renderer, canvas_pivot)
	if necklace:
		create_part_sprites(parent, necklace_renderer, canvas_pivot)
	if spear:
		create_part_sprites(parent, spear_renderer, canvas_pivot)
	elif sword:
		create_part_sprites(parent, sword_renderer, canvas_pivot)
	if shield:
		create_part_sprites(parent, shield_renderer, canvas_pivot)
	if shoes:
		create_part_sprites(parent, shoes_renderer, canvas_pivot)
	
	parent.character.attack_mode = "Stab-" if spear else "Slash-"
	parent.character.animate_string = "Weild-" if spear or sword else ""
	
	if Debug.debug_renderer_timings:
		print("[Character]: ---------- Loaded: ", Time.get_ticks_msec() - start_time, " ms\n")

func get_all_frames() -> Array[NTK_Frame]:
	var all_frames: Array[NTK_Frame] = []
	for part_renderer in part_renderers:
		if part_renderer.current_part < 0:
			continue
		all_frames.append_array(get_all_part_frames(part_renderer))

	return all_frames

func get_all_part_frames(part_renderer: NTK_PartRenderer) -> Array[NTK_Frame]:
	var all_frames: Array[NTK_Frame] = []
	var part: Part = part_renderer.dsc.parts[part_renderer.current_part]
	var frame_index := part.frame_index
	var max_frame_offset := 0
	for animation in part.animations:
		for animation_frame in animation.animation_frames:
			var frame_offset = animation_frame.frame_offset
			if frame_offset > max_frame_offset:
				max_frame_offset = frame_offset

	for i in range(max_frame_offset + 1):
		all_frames.append(part_renderer.get_frame(frame_index + i))
	return all_frames

# Creates and adds an AnimatedSprite2D of the specified
# part information to the parent scene
func create_part_sprites(
		parent: Node2D,
		part_renderer: NTK_PartRenderer,
		canvas_pivot: Pivot) -> void:
	if part_renderer.current_part < 0:
		return
	var sprite_frames := SpriteFrames.new()
	var part: Part = part_renderer.dsc.parts[part_renderer.current_part]
	var part_animations: Array[PartAnimation] = part.animations
	var part_name := part_renderer.part_name
	var sprite_sheet = create_part_spritesheet(canvas_pivot, part_renderer)
	for animation_string in NTK_Animations.PartAnimations.keys():
		if part_name not in NTK_Animations.PartAnimations[animation_string]:
			continue
		var animation_index = NTK_Animations.PartAnimations[animation_string][part_name]
		var sprite_sheet_texture := ImageTexture.create_from_image(sprite_sheet)
		sprite_frames.add_animation(animation_string)
		var animation_frame_count := len(part_animations[animation_index].animation_frames)
		for i in range(animation_frame_count):
			var atlas_texture := AtlasTexture.new()
			atlas_texture.atlas = sprite_sheet_texture
			var frame_offset := part_animations[animation_index].animation_frames[i].frame_offset
			var region_rect := Rect2i(canvas_pivot.width * frame_offset, 0, canvas_pivot.width, canvas_pivot.height)
			atlas_texture.region = region_rect
			sprite_frames.add_frame(animation_string, atlas_texture)
			sprite_frames.set_animation_loop(animation_string, true if 'Idle' in animation_string else false)
			if 'Walk' in animation_string:
				sprite_frames.set_animation_speed(animation_string, 10) # Need to find in DATs	
			elif "Kneel" in animation_string:
				sprite_frames.set_animation_speed(animation_string, 2) # Need to find in DATs
			elif "Pray" in animation_string:
				sprite_frames.set_animation_speed(animation_string, 2) # Need to find in DATs
			elif "Triumph" == animation_string:
				sprite_frames.set_animation_speed(animation_string, 1) # Need to find in DATs
			if animation_string not in animation_frames:
				animation_frames[animation_string] = []
			#if i == len(animation_frames[animation_string]):
				#animation_frames[animation_string].append(part_renderer.get_frame(part.frame_index + frame_offset))
			#else:
				#var part_frame := part_renderer.get_frame(part.frame_index + frame_offset)
				#var animation_frame: NTK_Frame = animation_frames[animation_string][i]
				#if part_frame.left < animation_frame.left:
					#animation_frame.left = part_frame.left
				#if part_frame.top < animation_frame.top:
					#animation_frame.top = part_frame.top
				#if part_frame.right > animation_frame.right:
					#animation_frame.right = part_frame.right
				#if part_frame.bottom > animation_frame.bottom:
					#animation_frame.bottom = part_frame.bottom
				#animation_frame.width = animation_frame.right - animation_frame.left
				#animation_frame.height = animation_frame.bottom - animation_frame.top

	var animated_sprite := AnimatedSprite2D.new()
	animated_sprite.name = part_name
	animated_sprite.frames = sprite_frames
	animated_sprite.animation = "Idle-Down"
	animated_sprite.z_as_relative = false
	animated_sprite.z_index = 1
	animated_sprite.y_sort_enabled = false

	parent.character.add_child(animated_sprite)
	parent.character.add_part_sprite(animated_sprite)

# Create Spritesheet from part info provided.
func create_part_spritesheet(
		canvas_pivot: Pivot,
		part_renderer: NTK_PartRenderer,
		palette_index=null) -> Image:
	var start_time := Time.get_ticks_msec()
	var part: Part = part_renderer.dsc.parts[part_renderer.current_part]
	var frame_index = part.frame_index
	palette_index = part_renderer.current_palette if part_renderer.current_palette != -1 else part.palette_index
	var frames: Array[NTK_Frame] = get_all_part_frames(part_renderer)
	var images := []
	for i in range(len(frames)):
		images.append(part_renderer.render_frame(frame_index + i, palette_index))

	var sprite_sheet := Image.create(canvas_pivot.width * len(images), canvas_pivot.height, false, Image.FORMAT_RGBA8)
	for offset in range(len(images)):
		var image: Image = images[offset]
		var frame: NTK_Frame = frames[offset]
		var frame_pivot = Pivot.get_pivot([frame])
		var image_rect := Rect2i(0, 0, frame.width, frame.height)
		var left = frame_pivot.x + abs(canvas_pivot.x)
		var top = frame_pivot.y + abs(canvas_pivot.y)
		var image_dst := Vector2i((canvas_pivot.width * offset) + left, top)
		sprite_sheet.blit_rect(image, image_rect, image_dst)

	if Debug.debug_renderer_timings:
		print("[Character]: ", part_renderer.part_name, "[", part_renderer.current_part, "-", palette_index, "] Spritesheet: ", Time.get_ticks_msec() - start_time, " ms")

	return sprite_sheet
