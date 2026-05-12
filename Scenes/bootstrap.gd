extends Control

@onready var wave = $Wave
@onready var http = $HTTPRequest

const PATH = "user://config.json"

func _ready() -> void:
	http.request("http://127.0.0.6:8000/ping")
	print_debug("bootstrap activated!")
	var cursor = Image.load_from_file("res://cursor.png")
	cursor.resize(36, 36)
	Input.set_custom_mouse_cursor(ImageTexture.create_from_image(cursor))
	pulse()
	load_config()

func _on_ping(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var json = JSON.parse_string(body.get_string_from_utf8())
	if ((response_code == 200) and (json["message"] == "pong")):
		await get_tree().create_timer(3.0).timeout
		get_out()
		await get_tree().create_timer(3.0).timeout
		get_tree().change_scene_to_file("res://Scenes/Main/Main.tscn")
	else:
		get_out()
		await get_tree().create_timer(1.0).timeout
		$Label.text = "Сервер не найден"

func get_out():
	var tween = create_tween()
	tween.tween_property(wave, "modulate:a", 0.0, 0.5)
	

func load_config():
	if FileAccess.file_exists(PATH):
		var file = FileAccess.open(PATH, FileAccess.READ)
		var text = file.get_as_text()
		var config = JSON.parse_string(text)
	else:
		create_default_config()

func create_default_config():
	var config = {"volume": 0.8, "fullscreen": false, "keybinds": {"left": "A", "right": "D" } }
	var file = FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(config))

func pulse() -> void:
	var tween = get_tree().create_tween()
	
	tween.set_loops()

	tween.tween_property(wave, "scale", Vector2(0.302, 0.302), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(wave, "scale", Vector2(0.282, 0.282), 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
func _process(delta: float) -> void:
	pass
