class_name ItemTblFileHandler extends NTK_FileHandler

const NTK_Item = preload("res://DataTypes/NTK_Item.gd")

var item_count := 0
var items := {}

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
		self.file_position = 0

	item_count = read_u32(file_position)
	file_position += 4
	for i in range(item_count):
		var item_index := read_u32(file_position)
		file_position += 4
		var palette_index := read_u32(file_position)
		file_position += 4
		var unknown_int_1 := read_s32(file_position)
		file_position += 4
		var unknown_int_2 := read_s32(file_position)
		file_position += 4
		var unknown_int_3 := read_s32(file_position)
		file_position += 4
		items[i] = NTK_Item.new(
			item_index, palette_index, unknown_int_1, unknown_int_2, unknown_int_3)
