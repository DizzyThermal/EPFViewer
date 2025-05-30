class_name NTK_Animations extends Node

const MobAnimations = {
	"Death": 0,
	"StandByNorth": 1,
	"StandByEast": 2,
	"StandBySouth": 3,
	"StandByWest": 4,
	"WalkNorth": 5,
	"WalkEast": 6,
	"WalkSouth": 7,
	"WalkWest": 8,
	"HurtNorth": 9,
	"HurtEast": 10,
	"HurtSouth": 11,
	"HurtWest": 12,
	"AttackNorth": 13,
	"AttackEast": 14,
	"AttackSouth": 15,
	"AttackWest": 16,
}

enum PartLayer {
	Body = 0x32, # 50
	Face = 0x33, # 51
	FaceDeco = 0x34, # 52
	Hair = 0x35, # 53
	HairDeco = 0x36, # 54
	MainWeapon = 0x37, # 55
	SubWeapon = 0x38, # 56
	Mantle = 0x39, # 57
	Shoes = 0x3A, # 58
	Necklace = 0x3B, # 59
	Riding = 0x3C, # 60
	All = 0x3D, # 61
	BackWeapon = 0x3E, # 62
}

const PartLayerIds = {
	# Part Layer ID			# Part Name
	PartLayer.Body: 		"Body",
	PartLayer.Face: 		"Face",
	PartLayer.FaceDeco: 	"FaceDec",
	PartLayer.Hair: 		"Hair",
	PartLayer.HairDeco: 	"HairDec",
	PartLayer.MainWeapon: 	"Weapon",
	PartLayer.SubWeapon: 	"Shield",
	PartLayer.Mantle:		"Mantle",
	PartLayer.Shoes:		"Shoes",
	PartLayer.Necklace:		"Necklace",
	PartLayer.Riding:		"Mount",
	PartLayer.All:			"All",
	PartLayer.BackWeapon:	"Coat",
}

const MotionAnimations = {
	"NormalWalkNorth": 0,
	"NormalWalkEast": 1,
	"NormalWalkSouth": 2,
	"NormalWalkWest": 3,
	"WeaponWalkNorth": 4,
	"WeaponWalkEast": 5,
	"WeaponWalkSouth": 6,
	"WeaponWalkWest": 7,
	"RidingNorth": 8,
	"RidingEast": 9,
	"RidingSouth": 10,
	"RidingWest": 11,
	"SwingNorth": 12,
	"SwingEast": 13,
	"SwingSouth": 14,
	"SwingWest": 15,
	"PierceNorth": 16,
	"PierceEast": 17,
	"PierceSouth": 18,
	"PierceWest": 19,
	"ShootNorth": 20,
	"ShootEast": 21,
	"ShootSouth": 22,
	"ShootWest": 23,
	"GetNorth": 24,
	"GetEast": 25,
	"GetSouth": 26,
	"GetWest": 27,
	"SpellNorth": 28,
	"SpellEast": 29,
	"SpellSouth": 30,
	"SpellWest": 31,
	"HandToMouth": 32,
	"BowNorth": 33,
	"BowEast": 34,
	"BowSouth": 35,
	"BowWest": 36,
	"Victory": 37,
	"Smile": 38,
	"Cry": 39,
	"Blush": 40,
	"Wink": 41,
	"Yawn": 42,
	"Sleep": 43,
	"Surprise": 44,
	"Angry": 45,
	"Merong": 46,
	"Kongi": 47,
	"Pish": 48,
	"Dance": 49,
	"Cold": 50,
	"KissNorth": 51,
	"KissEast": 52,
	"KissSouth": 53,
	"KissWest": 54,
	"NormalStandByNorth": 55,
	"NormalStandByEast": 56,
	"NormalStandBySouth": 57,
	"NormalStandByWest": 58,
	"WeaponStandByNorth": 59,
	"WeaponStandByEast": 60,
	"WeaponStandBySouth": 61,
	"WeaponStandByWest": 62,
	"Swing6North": 63,
	"Swing6East": 64,
	"Swing6South": 65,
	"Swing6West": 66,
	"Test": 67,
}

const PartAnimations = {
	"NormalWalkNorth": {
		"Body": 0,
		"Neck": 0,
		"Mantle": 0,
		"Face": 0,
		"Hair": 0,
		"HairDec": 0,
		"Shield": 0,
		"Shoes": 0,
	},
	"NormalWalkEast": {
		"Body": 1,
		"Neck": 1,
		"Mantle": 1,
		"Face": 1,
		"FaceDec": 1,
		"Hair": 1,
		"HairDec": 1,
		"Shield": 1,
		"Shoes": 1,
	},
	"NormalWalkSouth": {
		"Body": 2,
		"Neck": 2,
		"Mantle": 2,
		"Face": 2,
		"FaceDec": 2,
		"Hair": 2,
		"HairDec": 2,
		"Shield": 2,
		"Shoes": 2,
	},
	"NormalWalkWest": {
		"Body": 3,
		"Neck": 3,
		"Mantle": 3,
		"Face": 3,
		"FaceDec": 3,
		"Hair": 3,
		"HairDec": 3,
		"Shield": 3,
		"Shoes": 3,
	},
	"WeaponWalkNorth": {
		"Body": 4,
		"Neck": 4,
		"Mantle": 4,
		"Face": 4,
		"Hair": 4,
		"HairDec": 4,
		"Spear": 0,
		"Sword": 0,
		"Shield": 0,
		"Shoes": 4,
	},
	"WeaponWalkEast": {
		"Body": 5,
		"Neck": 5,
		"Mantle": 5,
		"Face": 5,
		"FaceDec": 5,
		"Hair": 5,
		"HairDec": 5,
		"Spear": 1,
		"Sword": 1,
		"Shield": 1,
		"Shoes": 5,
	},
	"WeaponWalkSouth": {
		"Body": 6,
		"Neck": 6,
		"Mantle": 6,
		"Face": 6,
		"FaceDec": 6,
		"Hair": 6,
		"HairDec": 6,
		"Spear": 2,
		"Sword": 2,
		"Shield": 2,
		"Shoes": 6,
	},
	"WeaponWalkWest": {
		"Body": 7,
		"Neck": 7,
		"Mantle": 7,
		"Face": 7,
		"FaceDec": 7,
		"Hair": 7,
		"HairDec": 7,
		"Spear": 3,
		"Sword": 3,
		"Shield": 3,
		"Shoes": 7,
	},
	"GetNorth": {
		"Body": 24,
		"Neck": 24,
		"Mantle": 24,
		"Face": 24,
		"Hair": 24,
		"HairDec": 24,
		"Shoes": 24,
	},
	"GetEast": {
		"Body": 25,
		"Neck": 25,
		"Mantle": 25,
		"Face": 25,
		"FaceDec": 25,
		"Hair": 25,
		"HairDec": 25,
		"Shoes": 25,
	},
	"GetSouth": {
		"Body": 26,
		"Neck": 26,
		"Mantle": 26,
		"Face": 26,
		"FaceDec": 26,
		"Hair": 26,
		"HairDec": 26,
		"Shoes": 26,
	},
	"GetWest": {
		"Body": 27,
		"Neck": 27,
		"Mantle": 27,
		"Face": 27,
		"FaceDec": 27,
		"Hair": 27,
		"HairDec": 27,
		"Shoes": 27,
	},
	"SwingNorth": {
		"Body": 12,
		"Neck": 12,
		"Mantle": 12,
		"Face": 12,
		"Hair": 12,
		"HairDec": 12,
		"Sword": 4,
		"Shield": 8,
		"Shoes": 12,
	},
	"SwingEast": {
		"Body": 13,
		"Neck": 13,
		"Mantle": 13,
		"Face": 13,
		"FaceDec": 13,
		"Hair": 13,
		"HairDec": 13,
		"Sword": 5,
		"Shield": 9,
		"Shoes": 13,
	},
	"SwingSouth": {
		"Body": 14,
		"Neck": 14,
		"Mantle": 14,
		"Face": 14,
		"FaceDec": 14,
		"Hair": 14,
		"HairDec": 14,
		"Sword": 6,
		"Shield": 10,
		"Shoes": 14,
	},
	"SwingWest": {
		"Body": 15,
		"Neck": 15,
		"Mantle": 15,
		"Face": 15,
		"FaceDec": 15,
		"Hair": 15,
		"HairDec": 15,
		"Sword": 7,
		"Shield": 11,
		"Shoes": 15,
	},
	"PierceNorth": {
		"Body": 16,
		"Neck": 16,
		"Mantle": 16,
		"Face": 16,
		"Hair": 16,
		"HairDec": 16,
		"Spear": 4,
		"Shield": 8,
		"Shoes": 16,
	},
	"PierceEast": {
		"Body": 17,
		"Neck": 17,
		"Mantle": 17,
		"Face": 17,
		"FaceDec": 17,
		"Hair": 17,
		"HairDec": 17,
		"Spear": 5,
		"Shield": 9,
		"Shoes": 17,
	},
	"PierceSouth": {
		"Body": 18,
		"Neck": 18,
		"Mantle": 18,
		"Face": 18,
		"FaceDec": 18,
		"Hair": 18,
		"HairDec": 18,
		"Spear": 6,
		"Shield": 10,
		"Shoes": 18,
	},
	"PierceWest": {
		"Body": 19,
		"Neck": 19,
		"Mantle": 19,
		"Face": 19,
		"FaceDec": 19,
		"Hair": 19,
		"HairDec": 19,
		"Spear": 7,
		"Shield": 11,
		"Shoes": 19,
	},
	"SpellNorth": {
		"Body": 28,
		"Neck": 28,
		"Mantle": 28,
		"Face": 28,
		"Hair": 28,
		"HairDec": 28,
		"Shoes": 28,
	},
	"SpellEast": {
		"Body": 29,
		"Neck": 29,
		"Mantle": 29,
		"Face": 29,
		"FaceDec": 29,
		"Hair": 29,
		"HairDec": 29,
		"Shoes": 29,
	},
	"SpellSouth": {
		"Body": 30,
		"Neck": 30,
		"Mantle": 30,
		"Face": 30,
		"FaceDec": 30,
		"Hair": 30,
		"HairDec": 30,
		"Shoes": 30,
	},
	"SpellWest": {
		"Body": 31,
		"Neck": 31,
		"Mantle": 31,
		"Face": 31,
		"FaceDec": 31,
		"Hair": 31,
		"HairDec": 31,
		"Shoes": 31,
	},
	"NormalStandByNorth": {
		"Body": 55,
		"Neck": 55,
		"Mantle": 55,
		"Face": 38,
		"Hair": 55,
		"HairDec": 55,
		"Shield": 12,
		"Shoes": 55,
	},
	"NormalStandByEast": {
		"Body": 56,
		"Neck": 56,
		"Mantle": 56,
		"Face": 39,
		"FaceDec": 1,
		"Hair": 56,
		"HairDec": 56,
		"Shield": 13,
		"Shoes": 56,
	},
	"NormalStandBySouth": {
		"Body": 57,
		"Neck": 57,
		"Mantle": 57,
		"Face": 40,
		"FaceDec": 2,
		"Hair": 57,
		"HairDec": 57,
		"Shield": 14,
		"Shoes": 57,
	},
	"NormalStandByWest": {
		"Body": 58,
		"Neck": 58,
		"Mantle": 58,
		"Face": 41,
		"FaceDec": 3,
		"Hair": 58,
		"HairDec": 58,
		"Shield": 15,
		"Shoes": 58,
	},
	"WeaponStandByNorth": {
		"Body": 59,
		"Neck": 59,
		"Mantle": 59,
		"Face": 38,
		"Hair": 55,
		"HairDec": 55,
		"Spear": 8,
		"Sword": 8,
		"Shield": 12,
		"Shoes": 59,
	},
	"WeaponStandByEast": {
		"Body": 60,
		"Neck": 60,
		"Mantle": 60,
		"Face": 39,
		"FaceDec": 1,
		"Hair": 56,
		"HairDec": 56,
		"Spear": 9,
		"Sword": 9,
		"Shield": 13,
		"Shoes": 60,
	},
	"WeaponStandBySouth": {
		"Body": 61,
		"Neck": 61,
		"Mantle": 61,
		"Face": 40,
		"FaceDec": 2,
		"Hair": 57,
		"HairDec": 57,
		"Spear": 10,
		"Sword": 10,
		"Shield": 14,
		"Shoes": 61,
	},
	"WeaponStandByWest": {
		"Body": 62,
		"Neck": 62,
		"Mantle": 62,
		"Face": 41,
		"FaceDec": 3,
		"Hair": 58,
		"HairDec": 58,
		"Spear": 11,
		"Sword": 11,
		"Shield": 15,
		"Shoes": 62,
	},
	"Victory": {
		"Body": 37,
		"Neck": 37,
		"Mantle": 37,
		"Face": 37,
		"FaceDec": 37,
		"Hair": 37,
		"HairDec": 37,
		"Shoes": 37,
	}
}
