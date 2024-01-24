class_name NTK_EffectRenderer extends NTK_Renderer

const EfxTblFileHandler = preload("res://FileHandlers/EfxTblFileHandler.gd")
const FrmFileHandler = preload("res://FileHandlers/FrmFileHandler.gd")
const NTK_Effect = preload("res://DataTypes/NTK_Effect.gd")
const NTK_EffectFrame = preload("res://DataTypes/NTK_EffectFrame.gd")

var efx: EfxTblFileHandler = null
var frm: FrmFileHandler = null
var dat_prefix := ""

var effects := {}
var effect_sprite_sheets := {}

func _numeric_sort(a: String, b: String) -> bool:
	if int(a.replace(dat_prefix, "").replace(".dat", "")) \
		< int(b.replace(dat_prefix, "").replace(".dat", "")):
		return true
	return false

func _init():
	var start_time := Time.get_ticks_msec()
	var efx_dat = DatFileHandler.new("efx.dat")

	efx = EfxTblFileHandler.new(efx_dat.get_file("effect.tbl"))
	frm = FrmFileHandler.new(efx_dat.get_file("EFFECT.FRM"))
	pal = PalFileHandler.new(efx_dat.get_file("EFFECT.PAL"))

	# EPFs
	var ntk_data_directory := DirAccess.open(Resources.data_dir)
	var datRegex := RegEx.new()
	datRegex.compile("efx[0-9]+.dat")

	var files := []
	for file_name in ntk_data_directory.get_files():
		var result := datRegex.search(file_name)
		if result:
			files.append(file_name)
	files.sort_custom(_numeric_sort)
	for i in range(len(files)):
		epfs.append(EpfFileHandler.new(DatFileHandler.new(files[i]).get_file("EFFECT" + String.num(i) + ".epf")))

	if Debug.debug_renderer_timings:
		print("[EffectRenderer]: ", Time.get_ticks_msec() - start_time, " ms")

func get_all_frames(effect_index: int) -> Array[NTK_Frame]:
	var all_frames: Array[NTK_Frame] = []
	var effect = efx.effects[effect_index]
	var effect_frames = effect.effect_frames
	var frame_count = len(effect_frames)
	for i in range(frame_count):
		all_frames.append(get_frame(effect_frames[i].frame_index))
	
	return all_frames

func create_effect(effect_index: int, palette_index=null) -> AnimatedSprite2D:
	var start_time := Time.get_ticks_msec()
	var effect_pivot := Pivot.get_pivot(get_all_frames(effect_index), true)
	var sprite_frames := SpriteFrames.new()
	var effect = efx.effects[effect_index]
	var effect_frames: Array[NTK_EffectFrame] = effect.effect_frames
	var sprite_sheet_key := String.num(effect_index) + "-" + String.num(palette_index)
	if sprite_sheet_key not in effect_sprite_sheets:
		effect_sprite_sheets[sprite_sheet_key] = create_effect_spritesheet(effect_index, effect_pivot, palette_index)
	var sprite_sheet_texture := ImageTexture.create_from_image(effect_sprite_sheets[sprite_sheet_key])
	sprite_frames.add_animation("Effect")
	
	var total_delay := 0
	for i in range(len(effect_frames)):
		var effect_frame := effect_frames[i]
		var atlas_texture := AtlasTexture.new()
		atlas_texture.atlas = sprite_sheet_texture
		var region_rect := Rect2i(effect_pivot.width * i, 0, effect_pivot.width, effect_pivot.height)
		atlas_texture.region = region_rect
		sprite_frames.add_frame("Effect", atlas_texture)
		sprite_frames.set_animation_loop("Effect", false)
		total_delay += effect_frame.frame_delay
	sprite_frames.set_animation_speed("Effect", 1000 / (float(total_delay) / len(effect_frames)))

	var animated_sprite := AnimatedSprite2D.new()
	animated_sprite.frames = sprite_frames
	animated_sprite.animation = "Effect"
	animated_sprite.z_as_relative = false
	animated_sprite.y_sort_enabled = false
	animated_sprite.z_index = 1
	
	if Debug.debug_renderer_timings:
		print("[Effect]: ------- Loaded: ", Time.get_ticks_msec() - start_time, " ms")

	return animated_sprite

func create_effect_spritesheet(
		effect_index: int,
		effect_pivot: Pivot,
		palette_index: int=-1) -> Image:
	var start_time := Time.get_ticks_msec()
	var effect = efx.effects[effect_index]
	var frames := []
	var images := []
	for i in range(len(effect.effect_frames)):
		frames.append(get_frame(effect.effect_frames[i].frame_index))
		var frame_palette := palette_index
		if frame_palette == -1:
			frame_palette = frm.palette_indices[effect.effect_frames[i].frame_index]
		images.append(render_frame(effect.effect_frames[i].frame_index, frame_palette))

	var sprite_sheet := Image.create(effect_pivot.width * len(images), effect_pivot.height, false, Image.FORMAT_RGBA8)
	for offset in range(len(images)):
		var image: Image = images[offset]
		var frame: NTK_Frame = frames[offset]
		var frame_pivot = Pivot.get_pivot([frame])
		var image_rect := Rect2i(0, 0, frame.width, frame.height)
		var left = frame_pivot.x + abs(effect_pivot.x)
		var top = frame_pivot.y + abs(effect_pivot.y)
		var image_dst := Vector2i((effect_pivot.width * offset) + left, top)
		sprite_sheet.blit_rect(image, image_rect, image_dst)

	if Debug.debug_renderer_timings:
		print("[Effect]: Effect[", effect_index, "] Spritesheet: ", Time.get_ticks_msec() - start_time, " ms")

	return sprite_sheet
