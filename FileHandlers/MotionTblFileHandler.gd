class_name MotionTblFileHandler extends NTK_FileHandler

const HEADER_SIZE := 0x1B
const NAME_LENGTH := 0x14

var motion_count := 0
var motions: Array[Dictionary] = []

func _init(file):
	super(file)
	file_position += NAME_LENGTH	# "MotionStandard"
	var unknown_byte := read_u8()
	var unknown_short := read_u16()	# 0x0001
	motion_count = read_u32()
	
	for i in range(motion_count):
		var id := read_u32()
		print(file_position)
		var motion_name := read_utf8(NAME_LENGTH)
		var unknown_byte_1 := read_u8()
		var unknown_int_1 := read_u32()
		var unknown_int_2 := read_u32()
		var unknown_short_1 := read_u16()
		var unknown_int_3 := read_u32()
		var unknown_int_4 := read_u32()
		var unknown_int_5 := read_u32()
		var unknown_int_6 := read_u32()
		var unknown_int_7 := read_u32()
		var unknown_int_8 := read_u32()
		var unknown_int_9 := read_u32()
		var unknown_int_10 := read_u32()
		var unknown_int_11 := read_u32()
		var unknown_int_12 := read_u32()
		var unknown_int_13 := read_u32()
		var unknown_int_14 := read_u32()
		file_position += 0x4A
		var unknown_int_15 := read_u32()
		var unknown_int_16 := read_u32()
		var unknown_int_17 := read_u32()
		var unknown_int_18 := read_u32()
		var unknown_int_19 := read_u32()
		var unknown_int_20 := read_u32()
		var unknown_int_21 := read_u32()
		var unknown_int_22 := read_u32()
		var unknown_int_23 := read_u32()
		var unknown_int_24 := read_u32()
		var unknown_int_25 := read_u32()
		var unknown_int_26 := read_u32()
		file_position += 0x4A
		var unknown_int_27 := read_u32()
		var unknown_int_28 := read_u32()
		var unknown_int_29 := read_u32()
		var unknown_int_30 := read_u32()
		var unknown_int_31 := read_u32()
		var unknown_int_32 := read_u32()
		var unknown_int_33 := read_u32()
		var unknown_int_34 := read_u32()
		var unknown_int_35 := read_u32()
		var unknown_int_36 := read_u32()
		var unknown_int_37 := read_u32()
		var unknown_int_38 := read_u32()
		file_position += 0x4A
		var unknown_int_39 := read_u32()
		var unknown_int_40 := read_u32()
		var unknown_int_41 := read_u32()
		var unknown_int_42 := read_u32()
		var unknown_int_43 := read_u32()
		var unknown_int_44 := read_u32()
		var unknown_int_45 := read_u32()
		var unknown_int_46 := read_u32()
		var unknown_int_47 := read_u32()
		var unknown_int_48 := read_u32()
		var unknown_int_49 := read_u32()
		var unknown_int_50 := read_u32()
		file_position += 0x4A
		var unknown_int_51 := read_u32()
		var unknown_int_52 := read_u32()
		var unknown_int_53 := read_u32()
		var unknown_int_54 := read_u32()
		var unknown_int_55 := read_u32()
		var unknown_int_56 := read_u32()
		var unknown_int_57 := read_u32()
		var unknown_int_58 := read_u32()
		var unknown_int_59 := read_u32()
		var unknown_int_60 := read_u32()
		var unknown_int_61 := read_u32()
		var unknown_int_62 := read_u32()
		file_position += 0x4A

		motions.append({
			"id": id,
			"motion_name": motion_name,
			"unknown_byte_1": unknown_byte_1,
			"unknown_int_1": unknown_int_1,
			"unknown_int_2": unknown_int_2,
			"unknown_int_3": unknown_int_3,
			"unknown_int_4": unknown_int_4,
			"unknown_int_5": unknown_int_5,
			"unknown_int_6": unknown_int_6,
			"unknown_int_7": unknown_int_7,
			"unknown_int_8": unknown_int_8,
			"unknown_int_9": unknown_int_9,
			"unknown_int_10": unknown_int_10,
			"unknown_int_11": unknown_int_11,
			"unknown_int_12": unknown_int_12,
			"unknown_int_13": unknown_int_13,
			"unknown_int_14": unknown_int_14,
			"unknown_int_15": unknown_int_15,
			"unknown_int_16": unknown_int_16,
			"unknown_int_17": unknown_int_17,
			"unknown_int_18": unknown_int_18,
			"unknown_int_19": unknown_int_19,
			"unknown_int_20": unknown_int_20,
			"unknown_int_21": unknown_int_21,
			"unknown_int_22": unknown_int_22,
			"unknown_int_23": unknown_int_23,
			"unknown_int_24": unknown_int_24,
			"unknown_int_25": unknown_int_25,
			"unknown_int_26": unknown_int_26,
			"unknown_int_27": unknown_int_27,
			"unknown_int_28": unknown_int_28,
			"unknown_int_29": unknown_int_29,
			"unknown_int_30": unknown_int_30,
			"unknown_int_31": unknown_int_31,
			"unknown_int_32": unknown_int_32,
			"unknown_int_33": unknown_int_33,
			"unknown_int_34": unknown_int_34,
			"unknown_int_35": unknown_int_35,
			"unknown_int_36": unknown_int_36,
			"unknown_int_37": unknown_int_37,
			"unknown_int_38": unknown_int_38,
			"unknown_int_39": unknown_int_39,
			"unknown_int_40": unknown_int_40,
			"unknown_int_41": unknown_int_41,
			"unknown_int_42": unknown_int_42,
			"unknown_int_43": unknown_int_43,
			"unknown_int_44": unknown_int_44,
			"unknown_int_45": unknown_int_45,
			"unknown_int_46": unknown_int_46,
			"unknown_int_47": unknown_int_47,
			"unknown_int_48": unknown_int_48,
			"unknown_int_49": unknown_int_49,
			"unknown_int_50": unknown_int_50,
			"unknown_int_51": unknown_int_51,
			"unknown_int_52": unknown_int_52,
			"unknown_int_53": unknown_int_53,
			"unknown_int_54": unknown_int_54,
			"unknown_int_55": unknown_int_55,
			"unknown_int_56": unknown_int_56,
			"unknown_int_57": unknown_int_57,
			"unknown_int_58": unknown_int_58,
			"unknown_int_59": unknown_int_59,
			"unknown_int_60": unknown_int_60,
			"unknown_int_61": unknown_int_61,
			"unknown_int_62": unknown_int_62,
		})
