extends Node2D

const color_tile_size := 16
const min_frame_size := 1
const max_frame_size := 16

const Indices = preload("res://DataTypes/Indices.gd")
const NTK_Frame = preload("res://DataTypes/NTK_Frame.gd")

@onready var epf_options: OptionButton = $UI/EpfOptions
@onready var epf_index_spinbox: SpinBox = $UI/EpfIndexSpinbox

@onready var type_index_label: Label = $UI/TypeIndexLabel
@onready var type_index_spinbox: SpinBox = $UI/TypeIndexSpinbox

@onready var frame_container: CenterContainer = $UI/FrameContainer

@onready var pal_options: OptionButton = $UI/PalOptions
@onready var pal_index_spinbox: SpinBox = $UI/PalIndexSpinbox
@onready var color_grid: GridContainer = $UI/ColorGrid
@onready var color_info_container: BoxContainer = $UI/ColorInfoContainer
@onready var color_info_index_label: Label = $UI/ColorInfoIndex
@onready var color_offset_spinbox: SpinBox = $UI/ColorOffsetSpinbox
@onready var reverse_animated_pallete_checkbox: CheckBox = $UI/ReverseCheckbox
@onready var animation_speed_slider: HSlider = $UI/AnimationSpeedSlider
@onready var animated_palettes_only_checkbox: CheckBox = $UI/AnimatedPalettesOnlyCheckbox
@onready var animated_palette_label: Label = $UI/AnimatedPaletteLabel

@onready var dat_list := {}
@onready var epf_list := {}
@onready var pal_list := {}

var offset_range: Array[int] = []

# Renderers
var renderer_threads: Array[Thread] = []

var mob_renderer: NTK_MobRenderer
var effect_renderer: NTK_EffectRenderer
var update_from_type: bool = true
var updating_epf_index: bool = false

# Debug Values (Set on load)

## Bandit
var debug_epf_key := "mon7.dat:mon7.epf"
var debug_pal_key := "mon.dat:monster.pal"
var debug_epf_index := 178
var debug_pal_index := 0
var debug_color_offset := 0
var debug_start_scale := Vector2(4, 4)

## Flameblade
#var debug_epf_key := "sword0.dat:Sword0.epf"
#var debug_pal_key := "char.dat:Sword.pal"
#var debug_epf_index := 86
#var debug_pal_index := 0
#var debug_color_offset := 0
#var debug_start_scale := Vector2(8, 8)

## Ox Boss
#var debug_epf_key := "mon4.dat:mon4.epf"
#var debug_pal_key := "mon.dat:monster.pal"
#var debug_epf_index := 208
#var debug_pal_index := 0
#var debug_color_offset := 160
#var debug_start_scale := Vector2(4, 4)

var current_epf_key := ""
var current_pal_key := ""

var frame_sprite: Sprite2D = null
var current_scale := Vector2(1, 1)

var animated_color_offset := 0

var last_palette_spinbox_value := 0
var current_palette_index := 0
var current_color_offset := 0

var render_cooldown := 0.0
var focused_spinbox: SpinBox = null
var spinbox_change_cooldown := 0.0

var dat_files: Array[String] = []
var mutex: Mutex = Mutex.new()

func _ready() -> void:
	var ntk_data_directory := DirAccess.open(Database.get_config_item_value("data_dir"))

	# Load EPFs and PALs
	var dat_indices: Array[int] = []
	for file_name in ntk_data_directory.get_files():
		if '.dat' in file_name:
			dat_files.append(file_name)
			dat_indices.append(len(dat_indices))

	var dat_task_id : int = WorkerThreadPool.add_group_task(process_dat, dat_indices.size(), 4, true)

	for i in range(48, 136):
		offset_range.append(i)
	for i in range(176, 256):
		offset_range.append(i)
	
	WorkerThreadPool.wait_for_group_task_completion(dat_task_id)
	populate_option_buttons()
	get_viewport().connect("gui_focus_changed", _on_focus_changed)

	# Create Renderers
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.mob_renderer = NTK_MobRenderer.new())
	renderer_threads.append(Thread.new())
	renderer_threads[-1].start(func(): self.effect_renderer = NTK_EffectRenderer.new())

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

	if debug_epf_key and debug_pal_key:
		epf_options.select(get_option_index(epf_options, debug_epf_key))
		pal_options.select(get_option_index(pal_options, debug_pal_key))
		load_pal(debug_pal_key, current_pal_key != debug_pal_key)
		current_pal_key = debug_pal_key
		load_frame(debug_epf_key, current_epf_key != debug_epf_key)
		current_epf_key = debug_epf_key
		epf_index_spinbox.value = debug_epf_index
		pal_index_spinbox.value = debug_pal_index
		if debug_color_offset:
			color_offset_spinbox.value = debug_color_offset
		_render(true)
		current_scale = debug_start_scale
		update_type_spinbox(epf_index_spinbox.value)

func _process(delta) -> void:
	if frame_sprite != null:
		if Input.is_action_just_pressed("zoom-in") and \
				frame_sprite.scale.x < max_frame_size and \
				over_sprite():
			frame_sprite.scale += Vector2(1, 1)
			current_scale = frame_sprite.scale
		elif Input.is_action_just_pressed("zoom-out") and \
				frame_sprite.scale.x > min_frame_size and \
				over_sprite():
			frame_sprite.scale -= Vector2(1, 1)
			current_scale = frame_sprite.scale
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and \
				over_sprite():
			var frame_image := "-".join([
				current_epf_key,
				epf_index_spinbox.value,
				current_pal_key,
				pal_index_spinbox.value,
				color_offset_spinbox.value,
				# animated_color_offset, # Confusing for static images
			]).replace(":", "-") + ".png"
			if not FileAccess.file_exists(Resources.desktop_dir + frame_image):
				Debug.save_png_to_desktop(frame_sprite.texture.get_image(), frame_image)

	render_cooldown -= delta
	if render_cooldown <= 0:
		var pal_key = pal_options.get_item_text(pal_options.selected)
		var palette_list = pal_list[pal_key]
		if reverse_animated_pallete_checkbox.button_pressed:
			animated_color_offset = animated_color_offset + 1
		else:
			animated_color_offset = animated_color_offset - 1
		if palette_list and len(palette_list.palettes) > 0:
			_render(false)
		render_cooldown = 1.4 / animation_speed_slider.value

	spinbox_change_cooldown -= delta
	
	if Input.is_action_just_pressed("increment_spinbox") or Input.is_action_just_pressed("decrement_spinbox"):
		spinbox_change_cooldown = 0

	if spinbox_change_cooldown <= 0:
		spinbox_change_cooldown = 0.2
		if Input.is_action_pressed("increment_spinbox") and focused_spinbox:
			if focused_spinbox == color_offset_spinbox:
				focused_spinbox.value += 8
			else:
				focused_spinbox.value += 1
		elif Input.is_action_pressed("decrement_spinbox") and focused_spinbox:
			if focused_spinbox == color_offset_spinbox:
				focused_spinbox.value -= 8
			else:
				focused_spinbox.value -= 1

func update_type_spinbox(frame_index: int) -> void:
	var mon_regex = RegEx.new()
	mon_regex.compile("mon[0-9]*.dat:mon([0-9])*.epf")
	var mon_search := mon_regex.search(current_epf_key)
	var efx_regex = RegEx.new()
	efx_regex.compile("efx[0-9]*.dat:EFFECT([0-9])*.epf")
	var efx_search := efx_regex.search(current_epf_key)
	if mon_search:
		type_index_label.text = "Monster Index (0-" + str(self.mob_renderer.dna.mob_count - 1) + "):"
		type_index_label.visible = true
		# Determine Mob Index from Frame Index
		var epf_index: int = int(mon_search.strings[1])
		if frame_index < 0:
			epf_index -= 1
		var total_frames: int = 0
		var global_frame_index: int = 0
		for epf_idx in range(epf_index + 1):
			total_frames += mob_renderer.epfs[epf_idx].frame_count
			if epf_idx < epf_index:
				global_frame_index += mob_renderer.epfs[epf_idx].frame_count
			elif frame_index < 0:
				global_frame_index += mob_renderer.epfs[epf_idx].frame_count - 1
				break
			else:
				global_frame_index += frame_index
				break
		if global_frame_index >= total_frames:
			epf_index += 1
			var epf_option_str: String = "mon%d.dat:mon%d.epf" % [epf_index, epf_index]
			epf_options.select(get_option_index(epf_options, epf_option_str))
			current_epf_key = epf_option_str
			load_frame(current_epf_key, true)
		var mob_index: int = -1
		for mob_idx in range(mob_renderer.dna.mob_count):
			if mob_index >= 0:
				break

			var mob: Mob = mob_renderer.dna.get_mob(mob_idx)
			var mob_frame_index = mob.frame_index
			for animation in mob.animations:
				if mob_index >= 0:
					break

				for animation_frame in animation.animation_frames:
					var animation_frame_offset: int = mob_frame_index + animation_frame.frame_offset
					if animation_frame_offset == global_frame_index:
						mob_index = mob_idx
						break

		type_index_spinbox.min_value = 0
		type_index_spinbox.max_value = self.mob_renderer.dna.mob_count - 1
		self.updating_epf_index = true
		type_index_spinbox.value = mob_index
		self.updating_epf_index = false
		type_index_spinbox.visible = true
	elif efx_search:
		type_index_label.text = "Effect Index (0-" + str(self.effect_renderer.efx.effect_count - 1) + "):"
		type_index_label.visible = true
		# Determine Effect Index from Frame Index
		var epf_index: int = int(efx_search.strings[1])
		if frame_index < 0:
			epf_index -= 1
		var total_frames: int = 0
		var global_frame_index: int = 0
		for epf_idx in range(epf_index + 1):
			total_frames += effect_renderer.epfs[epf_idx].frame_count
			if epf_idx < epf_index:
				global_frame_index += effect_renderer.epfs[epf_idx].frame_count
			elif frame_index < 0:
				global_frame_index += effect_renderer.epfs[epf_idx].frame_count - 1
				break
			else:
				global_frame_index += frame_index
				break
		if global_frame_index >= total_frames:
			epf_index += 1
			var epf_option_str: String = "efx%d.dat:EFFECT%d.epf" % [epf_index, epf_index]
			epf_options.select(get_option_index(epf_options, epf_option_str))
			current_epf_key = epf_option_str
			load_frame(current_epf_key, true)
		var effect_index: int = -1
		for effect_idx in range(effect_renderer.efx.effect_count):
			if effect_index >= 0:
				break

			var efx: NTK_Effect = effect_renderer.efx.effects[effect_idx]
			for effect_frame in efx.effect_frames:
				if effect_frame.frame_index == global_frame_index:
					effect_index = effect_idx
					break

		type_index_spinbox.min_value = 0
		type_index_spinbox.max_value = self.effect_renderer.efx.effect_count - 1
		self.updating_epf_index = true
		type_index_spinbox.value = effect_index
		self.updating_epf_index = false
		type_index_spinbox.visible = true
	else:
		type_index_label.visible = false
		type_index_spinbox.visible = false

func _on_focus_changed(control: Control) -> void:
	var parent_control := control.get_parent()

	if parent_control == epf_index_spinbox:
		focused_spinbox = epf_index_spinbox
	elif parent_control == color_offset_spinbox:
		focused_spinbox = color_offset_spinbox
	elif parent_control == pal_index_spinbox:
		focused_spinbox = pal_index_spinbox
	elif parent_control == type_index_spinbox:
		focused_spinbox = type_index_spinbox
	else:
		focused_spinbox = null

func process_dat(dat_file_name_index: int) -> void:
	var dat_file_name: String = dat_files[dat_file_name_index]
	mutex.lock()
	dat_list[dat_file_name] = DatFileHandler.new(dat_file_name)
	mutex.unlock()
	for dfile in dat_list[dat_file_name].files:
		if '.epf' in dfile.file_name.to_lower():
			var epf_key = dat_file_name + ":" + dfile.file_name
			mutex.lock()
			epf_list[epf_key] = {}
			mutex.unlock()
		if '.pal' in dfile.file_name.to_lower():
			var pal_key = dat_file_name + ":" + dfile.file_name
			mutex.lock()
			pal_list[pal_key] = {}
			mutex.unlock()

func _sort(a: String, b: String) -> bool:
	if a.to_lower() \
		< b.to_lower():
		return true
	return false

func populate_option_buttons() -> void:
	var sorted_epfs := epf_list.keys()
	sorted_epfs.sort_custom(_sort)
	for epf in sorted_epfs:
		if epf:
			self.epf_options.add_item(epf)

	var sorted_pals := pal_list.keys()
	sorted_pals.sort_custom(_sort)
	for pal in sorted_pals:
		if pal:
			self.pal_options.add_item(pal)

func over_sprite() -> bool:
	var container_rect := frame_container.get_rect()
	container_rect.position -= Vector2(300, 400)
	container_rect.size += Vector2(600, 800)

	return container_rect.has_point(get_global_mouse_position())

func load_pal(pal_key: String, reset: bool=false) -> void:
	current_pal_key = pal_key
	if not pal_list[pal_key]:
		var dat := DatFileHandler.new(pal_key.split(":")[0])
		pal_list[pal_key] = PalFileHandler.new(dat.get_file(pal_key.split(":")[1]))

	if reset:
		pal_index_spinbox.value = 0
		pal_index_spinbox.max_value = len(pal_list[pal_key].palettes)
		$UI/PalIndexLabel.text = "Palette Index (0-" + str(int(pal_index_spinbox.max_value - 1)) + "):"

func create_color_rect(
		color: Color,
		color_int: int=-1,
		size: Vector2=Vector2(color_tile_size, color_tile_size)) -> ColorRect:
	var color_rect := ColorRect.new()

	color_rect.color = color
	color_rect.custom_minimum_size = size
	
	if color_int >= 0:
		var color_label := Label.new()
		color_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		color_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		color_label.text = ("%x" % color_int).to_upper()
		color_label.custom_minimum_size = size
		color_label.add_theme_font_size_override("font_size", 8)
		color_rect.add_child(color_label)

	return color_rect

func clear_color_info() -> void:
	for child in color_info_container.get_children():
		child.queue_free()
		color_info_container.remove_child(child)
	color_info_index_label.text = ""

func update_color_info(color: Color, color_index: int) -> void:
	clear_color_info()

	color_info_container.add_child(create_color_rect(Color(color.r, 0, 0), color.r8))
	color_info_container.add_child(create_color_rect(Color(0, color.g, 0), color.g8))
	color_info_container.add_child(create_color_rect(Color(0, 0, color.b), color.b8))
	
	color_info_index_label.text = str(color_index)

func clear_grid() -> void:
	for child in color_grid.get_children():
		child.queue_free()
		color_grid.remove_child(child)

func load_frame(epf_key: String, reset: bool=false) -> void:
	current_epf_key = epf_key
	if not epf_list[epf_key]:
		var dat := DatFileHandler.new(epf_key.split(":")[0])
		epf_list[epf_key] = EpfFileHandler.new(dat.get_file(epf_key.split(":")[1]))

	if reset:
		epf_index_spinbox.value = 0
	epf_index_spinbox.max_value = epf_list[epf_key].frame_count
	$UI/EpfIndexLabel.text = "Frame Index (0-" + str(int(epf_index_spinbox.max_value - 1)) + ")"

func clear_frame_container() -> void:
	for child in frame_container.get_children():
		child.queue_free()
		frame_container.remove_child(child)

func update_spinboxes() -> void:
	if epf_index_spinbox.value == epf_index_spinbox.min_value:
		epf_index_spinbox.value = epf_index_spinbox.max_value - 1
	if epf_index_spinbox.value == epf_index_spinbox.max_value:
		epf_index_spinbox.value = epf_index_spinbox.min_value + 1

	if color_offset_spinbox.value == color_offset_spinbox.min_value:
		color_offset_spinbox.value = color_offset_spinbox.max_value - 1
	if color_offset_spinbox.value == color_offset_spinbox.max_value:
		color_offset_spinbox.value = color_offset_spinbox.min_value + 1

	if pal_index_spinbox.value == pal_index_spinbox.min_value:
		pal_index_spinbox.value = pal_index_spinbox.max_value - 1
	if pal_index_spinbox.value == pal_index_spinbox.max_value:
		pal_index_spinbox.value = pal_index_spinbox.min_value + 1

func _render(force_grid_render: bool=false) -> void:
	update_spinboxes()

	# Update Palette
	var pal_key = pal_options.get_item_text(pal_options.selected)
	var palette_updated = current_pal_key != pal_key
	load_pal(pal_key, current_pal_key != pal_key)
	current_pal_key = pal_key

	var palette = pal_list[pal_key].get_palette(pal_index_spinbox.value, 255)
	if palette == null:
		clear_frame_container()
		return

	animated_palette_label.text = "[Animated]" if len(palette.animation_ranges) > 0 else ""
	
	var epf_key = epf_options.get_item_text(epf_options.selected)
	load_frame(epf_key, current_epf_key != epf_key)
	current_epf_key = epf_key

	var epf_dat_name = epf_key.split(":")[0]
	var epf_name := epf_key.split(":")[1]

	var frame: NTK_Frame = epf_list[epf_key].get_frame(epf_index_spinbox.value, true)
	var dot_these_palettes := []
	for i in range(len(palette.colors)):
		if i != 0 and i in frame.raw_pixel_data_array:
			var dotted_index := i
			if len(offset_range) > 0 and i in offset_range:
				dotted_index = (i + int(color_offset_spinbox.value)) % Resources.palette_color_count
			dot_these_palettes.append(dotted_index)

	if palette_updated or \
			force_grid_render or \
			current_palette_index != pal_index_spinbox.value or \
			current_color_offset != color_offset_spinbox.value:
		current_palette_index = pal_index_spinbox.value
		current_color_offset = color_offset_spinbox.value

		clear_grid()
		for i in range(len(palette.colors)):
			var color = palette.colors[i]
			var color_rect := ColorRect.new()
			color_rect.custom_minimum_size = Vector2(color_tile_size, color_tile_size)
			color_rect.color = color
			color_rect.connect("mouse_entered", func(): self.update_color_info(color, i))
			color_rect.connect("mouse_exited", self.clear_color_info)
			if i in palette.animation_indices:
				var color_label := Label.new()
				var font_color = Color.BLACK if (color.r8*0.299 + color.g8*0.587 + color.b8*0.114) > 186 else Color.WHITE
				color_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				color_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				color_label.position += Vector2(2, 0)
				color_label.text = "A"
				color_label.custom_minimum_size = Vector2(color_tile_size, color_tile_size)
				color_label.add_theme_color_override("font_color", font_color)
				color_label.add_theme_font_size_override("font_size", 8)
				color_rect.add_child(color_label)
			if i in dot_these_palettes:
				var color_label := Label.new()
				var font_color = Color.BLACK if (color.r8*0.299 + color.g8*0.587 + color.b8*0.114) > 186 else Color.WHITE
				color_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				color_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				color_label.position += Vector2(-2, -9)
				color_label.text = "·"
				color_label.custom_minimum_size = Vector2(color_tile_size, color_tile_size)
				color_label.add_theme_color_override("font_color", font_color)
				color_label.add_theme_font_size_override("font_size", 24)
				color_rect.add_child(color_label)
			color_grid.add_child(color_rect)

	# Update Frame
	var pal_dat_name = pal_key.split(":")[0] 
	var pal_name = pal_key.split(":")[1]
	if epf_dat_name not in dat_list:
		dat_list[epf_dat_name] = DatFileHandler.new(epf_dat_name)
	if pal_dat_name not in dat_list:
		dat_list[pal_dat_name] = DatFileHandler.new(pal_dat_name)

	var frame_texture := ImageTexture.create_from_image(
		NTK_Renderer.get_image_with_file_handlers(
			dat_list[epf_dat_name],
			epf_list[epf_key],
			dat_list[pal_dat_name],
			pal_list[pal_key],
			epf_index_spinbox.value,
			pal_index_spinbox.value,
			animated_color_offset,
			color_offset_spinbox.value,
			false))

	if frame_texture:
		clear_frame_container()
		frame_sprite = Sprite2D.new()
		frame_sprite.texture = frame_texture
		frame_container.add_child(frame_sprite)
		frame_sprite.scale = current_scale
	else:
		clear_frame_container()

func get_option_index(
		option_button: OptionButton,
		option_string: String) -> int:
	var option_index := -1

	for i in range(option_button.item_count):
		var option_text := option_button.get_item_text(i)
		if option_text == option_string:
			option_index = i
			break
	
	return option_index

func match_palette() -> void:
	var epf_key = epf_options.get_item_text(epf_options.selected)
	if epf_key in ViewerResources.EpfPals:
		var pal_key = ViewerResources.EpfPals[epf_key]
		pal_options.select(get_option_index(pal_options, pal_key))

func _on_epf_options(index):
	match_palette()
	_render()
	update_type_spinbox(epf_index_spinbox.value)

func _on_pal_index_spinbox_value_changed(spinbox_value):
	# If the animate_palette_only_checkbox is pressed, the spinner should search for the next (or previous)
	# palette that has any matching animated palette indices.
	# (intersection of the palette animation indices and the frames palette indices).
	if animated_palettes_only_checkbox.button_pressed:
		var pal_key = pal_options.get_item_text(pal_options.selected)
		var counter: int = spinbox_value
		var positive_direction: int = counter - last_palette_spinbox_value > 0
		var first_check = true

		while first_check or counter != spinbox_value:
			first_check = false
			if counter > len(pal_list[pal_key].palettes) - 1:
				counter = 0
			var palette = pal_list[pal_key].palettes[counter]
			if not palette.animation_ranges:
				if positive_direction:
					counter = (counter + 1) % Resources.palette_color_count
				else:
					counter = (counter - 1) % Resources.palette_color_count
				continue
			pal_index_spinbox.value = counter
			last_palette_spinbox_value = counter
			break

	_render(false)

func get_unique_values(arr: Array) -> Array:
	var unique_arr = []
	for element in arr:
		if not unique_arr.has(element):
			unique_arr.append(element)
	return unique_arr

func _on_type_index_spinbox_value_changed(type_value: int):
	var mon_regex = RegEx.new()
	mon_regex.compile("mon[0-9]*.dat:mon([0-9])*.epf")
	var mon_search := mon_regex.search(current_epf_key)
	if mon_search:
		var mob: Mob = mob_renderer.dna.get_mob(type_value)
		var mob_frame_index = mob.frame_index + mob.animations[3].animation_frames[0].frame_offset if len(mob.animations) > 3 else mob.frame_index
		var indices: Indices = Indices.new(mob_frame_index, mob_renderer.epfs)
		var epf_index: int = indices.epf_index
		var frame_index: int = indices.frame_index
		var epf_option_str: String = "mon%d.dat:mon%d.epf" % [epf_index, epf_index]
		if current_epf_key != epf_option_str:
			epf_options.select(get_option_index(epf_options, epf_option_str))
			current_epf_key = epf_option_str
			load_frame(current_epf_key)
			epf_index_spinbox.max_value = epf_list[current_epf_key].frame_count
			$UI/EpfIndexLabel.text = "Frame Index (0-" + str(int(epf_index_spinbox.max_value - 1)) + ")"
		if self.update_from_type and not self.updating_epf_index:
			epf_index_spinbox.value = frame_index
		pal_index_spinbox.value = mob.palette_index
	var efx_regex = RegEx.new()
	efx_regex.compile("efx[0-9]*.dat:EFFECT([0-9])*.epf")
	var efx_search := efx_regex.search(current_epf_key)
	if efx_search:
		var efx: NTK_Effect = effect_renderer.efx.effects[type_value]
		var efx_frame_index = efx.effect_frames[0].frame_index
		var indices: Indices = Indices.new(efx_frame_index, effect_renderer.epfs)
		var epf_index: int = indices.epf_index
		var frame_index: int = indices.frame_index
		var epf_option_str: String = "efx%d.dat:EFFECT%d.epf" % [epf_index, epf_index]
		if current_epf_key != epf_option_str:
			epf_options.select(get_option_index(epf_options, epf_option_str))
			current_epf_key = epf_option_str
			load_frame(current_epf_key)
			epf_index_spinbox.max_value = epf_list[current_epf_key].frame_count
			$UI/EpfIndexLabel.text = "Frame Index (0-" + str(int(epf_index_spinbox.max_value - 1)) + ")"
		if self.update_from_type and not self.updating_epf_index:
			epf_index_spinbox.value = frame_index
		pal_index_spinbox.value = efx.effect_frames[0].palette_index

func _on_epf_index_spinbox_value_changed(epf_index: int):
	if not self.updating_epf_index:
		update_from_type = false
		update_type_spinbox(epf_index)
		update_from_type = true
	_render()
