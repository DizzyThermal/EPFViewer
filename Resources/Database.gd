extends Node

const default_data_dirs: Array[String] = [
	"C:\\Program Files\\KRU\\NexusTK\\Data",					# Windows 32-Bit Default
	"C:\\Program Files (x86)\\KRU\\NexusTK\\Data",				# Windows 64-Bit Default
	"${HOME}/.wine/drive_c/Program Files/KRU/NexusTK/Data",		# Linux (Wine 32-Bit)
	"./Data",													# Project Data Directory
]

var database_initialized: bool = false

var db: SQLite
const db_path := "res://config.db"

func _ready() -> void:
	db = SQLite.new()
	db.path = db_path
	db.open_db()

	# Check Database Tables (Initialize if any tables are missing)
	if not table_exists("config"):
		db.create_table("config", {
			"id": {
				"data_type":"integer",
				"primary_key":"true",
				"auto_increment":"true"
			},
			"config_key":	{"data_type":"text"},
			"config_value": {"data_type":"text"},
		})

	# Check Config Entries (Initialize if any config entries are missing)
	if not config_key_exists("data_dir"):
		var home_dir := OS.get_environment("HOME") if OS.get_environment("HOME") else OS.get_environment("USERPROFILE")
		for data_dir in default_data_dirs:
			data_dir = data_dir.replace("\\", "/").replace("${HOME}", home_dir)
			if FileAccess.file_exists(data_dir + "/tile.dat"):
				upsert_config_item("data_dir", data_dir)
				break

	database_initialized = true

func table_exists(table_name: String) -> bool:
	db.query("SELECT name FROM sqlite_master WHERE type='table' AND name='" + table_name + "';")
	return len(db.query_result) > 0

func get_config_item_value(config_key: String) -> String:
	var config_value: String = ""
	if config_key_exists(config_key):
		config_value = get_config_item(config_key)[0]['config_value']
	return config_value

func get_config_item(config_key: String) -> Array[Dictionary]:
	db.select_rows("config", "config_key == '%s'" % config_key, ["*"])
	return db.query_result

func config_key_exists(config_key: String) -> bool:
	return len(get_config_item(config_key)) > 0

# Update/Insert Config Item
func upsert_config_item(
		config_key: String,
		config_value: String) -> bool:
	if config_key_exists(config_key):
		return db.update_rows("config", "config_key == '%s'" % config_key, {"config_value": config_value})
	else:
		return db.insert_row("config", {
			"config_key": config_key,
			"config_value": config_value,
		})
