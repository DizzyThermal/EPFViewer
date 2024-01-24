class_name NTK_SoundRenderer extends Node

const GDScriptAudioImport = preload("res://ThirdParty/GDScriptAudioImport.gd")

var sound_dats := {}
var sound_map := {}
var sound_cache := {}

func _numeric_sort(a: String, b: String, dat_prefix: String="mus") -> bool:
	if int(a.replace(dat_prefix, "").replace(".dat", "")) \
		< int(b.replace(dat_prefix, "").replace(".dat", "")):
		return true
	return false

func _init():
	var start_time := Time.get_ticks_msec()
	# mus###.dat
	var ntk_data_directory := DirAccess.open(Resources.data_dir)
	var datRegex := RegEx.new()
	datRegex.compile("mus[0-9]+.dat")

	var files := []
	for file_name in ntk_data_directory.get_files():
		var result := datRegex.search(file_name)
		if result:
			files.append(file_name)
	files.sort_custom(_numeric_sort)
	for i in range(len(files)):
		var dat_file_name = files[i]
		sound_dats[dat_file_name] = DatFileHandler.new(dat_file_name)
		for file in sound_dats[dat_file_name].files:
			sound_map[file.file_name] = dat_file_name

	# snd.dat
	sound_dats["snd.dat"] = DatFileHandler.new("snd.dat")
	for file in sound_dats["snd.dat"].files:
		sound_map[file.file_name] = "snd.dat"
	
	if Debug.debug_renderer_timings:
		print("[SoundRenderer]: ", Time.get_ticks_msec() - start_time, " ms")

func get_sound(
		sound_name: String,
		loop: bool=false) -> AudioStream:
	var audio_stream = null

	if sound_name in sound_map:
		var sound_dat = sound_map[sound_name]
		var sound_bytes = sound_dats[sound_dat].get_file(sound_name)
		if 'mp3' in sound_name:
			audio_stream = AudioStreamMP3.new()
			audio_stream.data = sound_bytes
		elif 'wav' in sound_name.to_lower():
			var unsigned_8bit = false
			if 'WAV' in sound_name:
				unsigned_8bit = true
			audio_stream = GDScriptAudioImport.create_wav_stream(sound_bytes, loop, unsigned_8bit)

	return audio_stream

func load_sound(
		sound_name: String,
		loop: bool=false) -> AudioStreamPlayer:
	if sound_name not in sound_cache:
		sound_cache[sound_name] = get_sound(sound_name, loop)

	var audio_stream_player = AudioStreamPlayer.new()
	audio_stream_player.stream = sound_cache[sound_name]

	if not loop:
		audio_stream_player.connect("finished", audio_stream_player.queue_free)

	return audio_stream_player
