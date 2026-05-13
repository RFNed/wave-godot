extends Node

var config = ConfigFile.new()
const USER_CONFIG = "user://config.cfg"

func load_config() -> void:
	var loaded = config.load(USER_CONFIG)
	if loaded != OK:
		init_config()

func init_config() -> void:
	config.set_value("user", "session", "null")
	var err = config.save(USER_CONFIG)
