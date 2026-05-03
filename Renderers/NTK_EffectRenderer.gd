class_name NTK_EffectRenderer extends NTK_Renderer

var efx: EfxTblFileHandler
var frm: FrmFileHandler
var dat_prefix: String = ""

func _numeric_sort(a: String, b: String) -> bool:
	if int(a.replace(dat_prefix, "").replace(".dat", "")) \
		< int(b.replace(dat_prefix, "").replace(".dat", "")):
		return true
	return false

func _init():
	var start_time: int = Time.get_ticks_msec()

	var efx_dat: DatFileHandler = DatFileHandler.new("efx.dat")
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
		epfs.append(EpfFileHandler.new(DatFileHandler.new(files[i]).get_file("EFFECT" + str(i) + ".epf")))

	if Debug.debug_renderer_timings:
		print("[EffectRenderer]: ", Time.get_ticks_msec() - start_time, " ms")

func get_effect_frame_count(effect_index: int) -> int:
	return len(efx.effects[effect_index].effect_frames)

func get_effect_frame_delay(effect_index: int, frame_offset: int) -> int:
	return efx.effects[effect_index].effect_frames[frame_offset].frame_delay

func get_effect_frame_sprite(
		effect_index: int,
		frame_offset: int,
		color_offset: int=0) -> FrameSprite:
	var effect_frame: NTK_EffectFrame = efx.effects[effect_index].effect_frames[frame_offset]
	var ntk_frame: NTK_Frame = self.get_frame(effect_frame.frame_index)
	var palette_index: int = frm.palette_indices[effect_frame.frame_index]
	var palette: Palette = self.pal.get_palette(palette_index)
	var frame_key: String = "-".join([
		"Effect",
		effect_frame.frame_index,
		effect_frame.palette_index,
		color_offset,
	])
	return FrameSprite.new(frame_key, ntk_frame, palette, color_offset)
