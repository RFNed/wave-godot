extends Control

@onready var background = $background
var target_pos := Vector2.ZERO
@onready var auth := $AuthContainer

var authIsOpened := false
var tween: Tween
var global_profile_id = 0
var closed_pos = Vector2.ZERO
var open_offset = Vector2(0, -30)

func _ready() -> void:
	Config.load_config()
	var value_user = Config.config.get_value("user", "session")
	
	if value_user == "null":
		$BottomBar/HBoxContainer/MarginContainer/Login.visible = true
	else:
		$BottomBar/HBoxContainer/MarginContainer/Avatar.visible = true
	
	$BottomBar/HBoxContainer/MarginContainer/Avatar/me.request("http://127.0.0.6:8000/megame", ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify({"session": Config.config.get_value("user", "session")}))
	await get_tree().process_frame
	closed_pos = auth.position
	auth.modulate.a = 0.0
	auth.visible = false

func _process(delta: float) -> void:
	var mouse = get_viewport().get_mouse_position()
	var center = Vector2(get_viewport().size) * 0.5

	target_pos = (mouse - center) * -0.02

	background.position = background.position.lerp(target_pos, 100.0 * delta)

func AuthContainerUsing() -> void:
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	var hidden_offset = -30.0

	if authIsOpened:
		auth.visible = true

		auth.modulate.a = 0.0
		auth.position = closed_pos
		auth.position.y += hidden_offset

		tween.set_parallel(true)

		tween.tween_property(
			auth,
			"position:y",
			closed_pos.y,
			0.25
		)

		tween.tween_property(
			auth,
			"modulate:a",
			1.0,
			0.2
		)

	else:
		tween.set_parallel(true)

		tween.tween_property(
			auth,
			"position:y",
			closed_pos.y + hidden_offset,
			0.25
		)

		tween.tween_property(
			auth,
			"modulate:a",
			0.0,
			0.2
		)

		tween.chain().tween_callback(func():
			auth.visible = false
			auth.position = closed_pos
		)

func _on_login_pressed() -> void:
	authIsOpened = !authIsOpened
	AuthContainerUsing()


func _on_me_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		return
	var data = JSON.parse_string(body.get_string_from_utf8())
	global_profile_id = int(data['profile_id'])
	$BottomBar/HBoxContainer/MarginContainer/Avatar/profile.request("http://127.0.0.6:8000/profile?id=%s" % data["profile_id"])


func get_image_url(path: String) -> String:
	if path.begins_with("http://") or path.begins_with("https://"):
		return path
	
	return "%s/%s" % ["http://127.0.0.6:8000", path]

func _on_profile_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		return
	var data = JSON.parse_string(body.get_string_from_utf8())
	
	data['avatar_url'] = str(data['avatar_url']).replace("\\", "/")
	$BottomBar/HBoxContainer/MarginContainer/Avatar/image.request(get_image_url(data['avatar_url']))



func _on_image_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		return
	var image = Image.new()
	
	var error = image.load_jpg_from_buffer(body)
	if error != OK:
		error = image.load_png_from_buffer(body)
	var texture = ImageTexture.create_from_image(image)
	$BottomBar/HBoxContainer/MarginContainer/Avatar.texture = texture


func _on_avatar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			OS.shell_open("http://127.0.0.6:5173/profile?id=%d" % global_profile_id)
