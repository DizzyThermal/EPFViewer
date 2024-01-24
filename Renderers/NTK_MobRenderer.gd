class_name NTK_MobRenderer extends NTK_Renderer

const Mob = preload("res://DataTypes/Mob.gd")
const MobCharacter = preload("res://Scenes/MobCharacter.tscn")

var dna: DnaFileHandler = null
var dat_prefix := ""

var mobs := {}
var animation_frames := {}
var mob_sprite_sheets := {}

func _numeric_sort(a: String, b: String) -> bool:
	if int(a.replace(dat_prefix, "").replace(".dat", "")) \
		< int(b.replace(dat_prefix, "").replace(".dat", "")):
		return true
	return false

func _init():
	var start_time := Time.get_ticks_msec()
	var mon_dat := DatFileHandler.new("mon.dat")

	dna = DnaFileHandler.new(mon_dat.get_file("monster.dna"))
	pal = PalFileHandler.new(mon_dat.get_file("monster.pal"))

	# EPFs
	var ntk_data_directory := DirAccess.open(Resources.data_dir)
	var datRegex := RegEx.new()
	datRegex.compile("mon[0-9]+.dat")

	var files := []
	for file_name in ntk_data_directory.get_files():
		var result := datRegex.search(file_name)
		if result:
			files.append(file_name)
	files.sort_custom(_numeric_sort)
	for file_name in files:
		epfs.append(EpfFileHandler.new(DatFileHandler.new(file_name).get_file(file_name.replace("dat", "epf"))))
	
	if Debug.debug_renderer_timings:
		print("[MobRenderer]: ", Time.get_ticks_msec() - start_time, " ms")

func get_all_frames(mob_index) -> Array[NTK_Frame]:
	var all_frames: Array[NTK_Frame] = []
	var mob: Mob = dna.get_mob(mob_index)
	var frame_index := mob.frame_index
	var max_frame_offset := 0
	for animation in mob.animations:
		for animation_frame in animation.animation_frames:
			var frame_offset = animation_frame.frame_offset
			if frame_offset > max_frame_offset:
				max_frame_offset = frame_offset

	for i in range(max_frame_offset + 1):
		all_frames.append(get_frame(frame_index + i))

	return all_frames

func create_mob(
		mob_index: int,
		palette_index=-1,
		direction="Down") -> MobCharacter:
	var start_time := Time.get_ticks_msec()
	var canvas_pivot = Pivot.get_pivot(get_all_frames(mob_index), true)
	var sprite_frames := SpriteFrames.new()
	var mob = dna.get_mob(mob_index)
	var mob_animations: Array[MobAnimation] = mob.animations
	var sprite_sheet_key := String.num(mob_index) + "-" + String.num(palette_index)
	if sprite_sheet_key not in mob_sprite_sheets:
		mob_sprite_sheets[sprite_sheet_key] = create_mob_spritesheet(mob_index, canvas_pivot, palette_index)
	for animation_string in NTK_Animations.MobAnimations.keys():
		var animation_index = NTK_Animations.MobAnimations[animation_string]
		sprite_frames.add_animation(animation_string)
		var animation_frame_count := len(mob_animations[animation_index].animation_frames)
		var sprite_sheet_texture := ImageTexture.create_from_image(mob_sprite_sheets[sprite_sheet_key])
		var total_duration := 0
		for i in range(animation_frame_count):
			var animation := mob_animations[animation_index].animation_frames[i]
			var atlas_texture := AtlasTexture.new()
			atlas_texture.atlas = sprite_sheet_texture
			var frame_offset := animation.frame_offset
			var region_rect := Rect2i(canvas_pivot.width * frame_offset, 0, canvas_pivot.width, canvas_pivot.height)
			atlas_texture.region = region_rect
			sprite_frames.add_frame(animation_string, atlas_texture)
			sprite_frames.set_animation_loop(animation_string, true if 'Idle' in animation_string else false)
			if animation_string not in animation_frames:
				animation_frames[animation_string] = []
			animation_frames[animation_string].append(get_frame(mob.frame_index + frame_offset))
			total_duration += animation.duration
		sprite_frames.set_animation_speed(animation_string, 1000 / (float(total_duration) / animation_frame_count))

	var animated_sprite := AnimatedSprite2D.new()
	animated_sprite.frames = sprite_frames
	animated_sprite.animation = "Idle-" + direction
	animated_sprite.z_as_relative = false
	animated_sprite.z_index = 1
	animated_sprite.y_sort_enabled = true

	var mob_body := MobCharacter.instantiate()
	mob_body.add_child(animated_sprite)
	mob_body.set_sprite(animated_sprite)

	if Debug.debug_renderer_timings:
		print("[Mob]: ------------ Loaded: ", Time.get_ticks_msec() - start_time, " ms\n")
	if mob_index in Debug.debug_mob_indices:
		var indices := Indices.new(mob.frame_index, epfs)
		print("[Mob]: Frame Index: ", mob.frame_index)
		print("[Mob]: Dat: mon", indices.epf_index, ".dat (Frame: ", indices.frame_index, ")")

	return mob_body

func create_mob_spritesheet(
		mob_index: int,
		canvas_pivot: Pivot,
		palette_index=-1) -> Image:
	var start_time := Time.get_ticks_msec()
	var mob: Mob = dna.get_mob(mob_index)
	var frame_index = mob.frame_index
	var frames: Array[NTK_Frame] = get_all_frames(mob_index)
	var images := []
	for i in range(len(frames)):
		images.append(render_frame(frame_index + i, palette_index))

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
		var sprite_sheet_key := String.num(mob_index) + "-" + String.num(palette_index)
		print("[Mob]: Mob[", mob_index , "] Spritesheet[", sprite_sheet_key, "]: ", Time.get_ticks_msec() - start_time, " ms")

	return sprite_sheet
