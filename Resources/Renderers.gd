extends Node

var bint0_dat: DatFileHandler
var bint1_dat: DatFileHandler
var bint2_dat: DatFileHandler
var char_dat: DatFileHandler
var misc_dat: DatFileHandler
var motion_tbl: MotionTblFileHandler

# Stage 1 Renderers
var character_renderer: NTK_CharacterRenderer

# Stage 2 Renderers
var mob_renderer: NTK_MobRenderer
var effect_renderer: NTK_EffectRenderer

var stage2_started := false
var stage2_complete := false
var stage2_start_time := 0
var stage2_load_time := 0

var renderer_threads: Array[Thread] = []
var num_of_renderers := 0
var renderers_ready := 0

func _ready():
	# Open DATs
	bint0_dat = DatFileHandler.new("bint0.dat")
	bint1_dat = DatFileHandler.new("bint1.dat")
	bint2_dat = DatFileHandler.new("bint2.dat")
	char_dat = DatFileHandler.new("char.dat")
	misc_dat = DatFileHandler.new("misc.dat")
	
	# Open TBLs
	motion_tbl = MotionTblFileHandler.new(char_dat.get_file("Motion.tbl"))

	# Create Stage 1 Renderers (Threaded)
	var start_time := Time.get_ticks_msec()

	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.character_renderer = NTK_CharacterRenderer.new())

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
	renderer_threads.clear()

	if Debug.debug_renderer_timings:
		print("\nRenderers - Stage 1: ", Time.get_ticks_msec() - start_time, " ms\n")

func _process(delta):
	if not stage2_started:
		# Load other Renderers in the background
		stage2_start_time = Time.get_ticks_msec()

		renderer_threads.append(Thread.new())
		renderer_threads[-1].start(func(): self.mob_renderer = NTK_MobRenderer.new())
		num_of_renderers += 1
		renderer_threads.append(Thread.new())
		renderer_threads[-1].start(func(): self.effect_renderer = NTK_EffectRenderer.new())
		num_of_renderers += 1

		stage2_started = true
	if not stage2_complete:
		# Wait for all renderer threads to finish
		var all_finished := true
		var indicies_to_delete: Array[int] = []
		for idx in range(len(renderer_threads)):
			var renderer_thread := renderer_threads[idx]
			if renderer_thread.is_alive():
				all_finished = false
			else:
				# Insert in reverse order so we can delete without worrying about
				# the size of the array changing as we're deleting
				indicies_to_delete.insert(0, idx)
				renderers_ready += 1
		for idx in indicies_to_delete:
			renderer_threads[idx].wait_to_finish()
			renderer_threads.remove_at(idx)

		if all_finished:
			if Debug.debug_renderer_timings:
				print("\nRenderers - Stage 2: ", Time.get_ticks_msec() - stage2_start_time, " ms\n")
			for thread in renderer_threads:
				thread.wait_to_finish()
			renderer_threads.clear()
			stage2_complete = true
			stage2_load_time = Time.get_ticks_msec() - Renderers.stage2_start_time
