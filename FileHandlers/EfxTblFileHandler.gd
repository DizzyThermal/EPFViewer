class_name EfxTblFileHandler extends NTK_FileHandler

const NTK_Effect = preload("res://DataTypes/NTK_Effect.gd")
const NTK_EffectFrame = preload("res://DataTypes/NTK_EffectFrame.gd")

var TBL_MASK := 0x7F
var HEADER_SIZE := 0x4
var FRAME_SIZE := 0x2

var effect_count := 0
var effects := {}

# IDFK
func decode_bytes(
		offset: int,
		encoded_bytes: PackedByteArray) -> PackedByteArray:
	var decoded_bytes = PackedByteArray()
	decoded_bytes.resize(4)
	var decode_array := [ 75, 25, 31, 29, 26, 9, 12, 12, 83, 73, 19, 17, 29, 23, 6, 29, 9, 6, 8, 27, 28, 1, 30, 29, 3, 5, 9 ]
	for i in range(26):
		decode_array[i+1] ^= decode_array[i]
	
	var pre := -0x1234568 - offset
	pre = pre & 0x00000000FFFFFFFF
	var reverse_idx = pre % 0x1B
	
	for i in range(8):
		var unsigned_byte = encoded_bytes.decode_u8(i)
		unsigned_byte ^= decode_array[reverse_idx]
		encoded_bytes.encode_u8(i, unsigned_byte)
		
		pre = (reverse_idx + 26)
		pre = pre & 0x00000000FFFFFFFF
		reverse_idx = pre % 0x1B

	var first := encoded_bytes.decode_u32(0) & 0xFFFFFFFF
	var second := encoded_bytes.decode_u32(4) & 0xFFFFFFFF

	decoded_bytes.encode_u32(0, (first ^ (first ^ second) & 0x55555555))

	return decoded_bytes
		
func _init(file, decode=true):
	super(file)
	var file_position: int = 0

	var bytes := PackedByteArray()
	bytes.resize(file_size / 2)
	if decode:
		var offset := 0
		for i in range(file_size / 8):
			var decoded_bytes := decode_bytes(offset, read_bytes(file_position, 8))
			file_position += 8
			for j in range(4):
				bytes.encode_u8((i * 4) + j, decoded_bytes.decode_u8(3 - j))
			offset += 4
		self.file_bytes = bytes
		file_position = 0
	
	effect_count = read_u32(file_position)
	file_position += 4
	for i in range(effect_count):
		var effect_index := read_u32(file_position)
		file_position += 4
		var frame_count := read_u32(file_position)
		file_position += 4
		
		if frame_count == 0:
			file_position += 8
			frame_count = read_u32(file_position)
			file_position += 4
			file_position += 8
		else:
			file_position += 20
		
		var effect_frames: Array[NTK_EffectFrame] = []
		for j in range(frame_count):
			var frame_index := read_s32(file_position)
			file_position += 4
			if frame_index == -1:
				while frame_index != i + 1:
					if frame_index == -1:
						file_position += 12
					else:
						var frame_delay := read_s32(file_position)
						file_position += 4
						var palette_index := read_u32(file_position)
						file_position += 4
						var unknown := read_u32(file_position)
						file_position += 4
						effect_frames.append(NTK_EffectFrame.new(frame_index, frame_delay, palette_index, unknown))
					frame_index = read_s32(file_position)
					file_position += 4
				
				file_position -= 4
				break
			var frame_delay := read_s32(file_position)
			file_position += 4
			var palette_index := read_u32(file_position)
			file_position += 4
			var unknown := read_u32(file_position)
			file_position += 4
			
			effect_frames.append(NTK_EffectFrame.new(frame_index, frame_delay, palette_index, unknown))
		effects[i] = NTK_Effect.new(effect_index, frame_count, effect_frames)
