class_name NTK_MobRenderer extends NTK_Renderer

const Mob = preload("res://DataTypes/Mob.gd")

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
