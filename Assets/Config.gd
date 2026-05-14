extends Node

var config = ConfigFile.new()
const USER_CONFIG = "user://config.cfg"
const HOST_SERVER = "http://127.0.0.6:8000"
const HOST_WEBSITE = "http://127.0.0.6:5173"
func load_config() -> void:
	var loaded = config.load(USER_CONFIG)
	if loaded != OK:
		init_config()

func init_config() -> void:
	config.set_value("user", "session", "null")
	var err = config.save(USER_CONFIG)
