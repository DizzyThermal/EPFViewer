class_name DnaFileHandler extends NTK_FileHandler

var mob_count := 0
var mobs := {}

var last_file_position := 4

func _init(file):
	super(file)
	var file_position: int = 0
	
	mob_count = read_u32(file_position)
	file_position += 4
	last_file_position = file_position

func get_mob(mob_index: int) -> Mob:
	if mob_index in mobs:
		return mobs[mob_index]

	var file_position: int = last_file_position
	for i in range(len(mobs), mob_count):
		var frame_index := read_u32(file_position)
		file_position += 4
		var animation_count := read_u8(file_position)
		file_position += 1
		var unknown_byte := read_u8(file_position)
		file_position += 1
		var palette_index := read_u16(file_position)
		file_position += 2

		var animations: Array[MobAnimation] = []
		for j in range(animation_count):
			var animation_frame_count := read_u16(file_position)
			file_position += 2
			var animation_frames: Array[MobAnimationFrame] = []
			for k in range(animation_frame_count):
				var frame_offset := read_s16(file_position)
				file_position += 2
				var duration := read_s16(file_position)
				file_position += 2
				var unknown_id_1 := read_s16(file_position)
				file_position += 2
				var alpha := read_u8(file_position)
				file_position += 1
				var unknown_id_2 := read_u8(file_position)
				file_position += 1
				var unknown_id_3 := read_u8(file_position)
				file_position += 1
				
				animation_frames.append(MobAnimationFrame.new(frame_offset, duration, unknown_id_1, alpha, unknown_id_2, unknown_id_3))
			animations.append(MobAnimation.new(animation_frame_count, animation_frames))
		mobs[i] = Mob.new(frame_index, animation_count, unknown_byte, palette_index, animations)
		if mob_index == i:
			last_file_position = file_position
			return mobs[i]

	return mobs[mob_index]
