class_name NTK_PartRenderer extends NTK_Renderer

const Part = preload("res://DataTypes/Part.gd")

var dsc: DscFileHandler = null
var motion: MotionTblFileHandler = null
var dat_prefix := ""

var part_name := ""
var part_count := 0

var current_part := -1
var current_palette := -1

func _numeric_sort(a: String, b: String) -> bool:
	if int(a.replace(dat_prefix, "").replace(".dat", "")) \
		< int(b.replace(dat_prefix, "").replace(".dat", "")):
		return true
	return false

func _init(
		part_name: String,
		char_dat: DatFileHandler,
		misc_dat: DatFileHandler,
		dat_prefix=null,
		dsc_prefix=null,
		epf_prefix=null,
		pal_prefix=null):
	var start_time := Time.get_ticks_msec()
	self.part_name = part_name
	dat_prefix = dat_prefix if dat_prefix else part_name.to_lower()
	dsc_prefix = dsc_prefix if dsc_prefix else part_name
	epf_prefix = epf_prefix if epf_prefix else part_name
	pal_prefix = pal_prefix if pal_prefix else part_name

	# DSC
	dsc = DscFileHandler.new(char_dat.get_file(dsc_prefix + ".dsc"))
	part_count = dsc.part_count
	if part_name in Debug.debug_part_dsc:
		dsc.print_part_info(Debug.debug_part_dsc[part_name], part_name)
	# Motion
	# motion = MotionTblFileHandler.new(char_dat.get_file("Motion.tbl"))
	# PAL
	if char_dat.contains_file(pal_prefix + ".pal") and 'misc:' not in pal_prefix:
		pal = PalFileHandler.new(char_dat.get_file(pal_prefix + ".pal"))
	else:
		var prefix = pal_prefix.replace("misc:", "")
		pal = PalFileHandler.new(misc_dat.get_file(prefix + ".pal"))

	# EPFs
	var ntk_data_directory := DirAccess.open(Resources.data_dir)
	var datRegex := RegEx.new()
	datRegex.compile("(?i)" + dat_prefix + "[0-9]+.dat")

	var files := []
	for file_name in ntk_data_directory.get_files():
		var result := datRegex.search(file_name)
		if result:
			files.append(file_name)
	files.sort_custom(_numeric_sort)
	for file_name in files:
		epfs.append(EpfFileHandler.new(DatFileHandler.new(file_name).get_file(file_name.replace("dat", "epf"))))
	
	if Debug.debug_renderer_timings:
		print("[PartRenderer]: [", part_name, "]: ", Time.get_ticks_msec() - start_time, " ms")
