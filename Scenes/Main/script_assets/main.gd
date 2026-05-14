extends Control

@onready var background: TextureRect = $background
@onready var auth: Control = $AuthContainer

@onready var login_button = $BottomBar/HBoxContainer/MarginContainer/Login
@onready var avatar = $BottomBar/HBoxContainer/MarginContainer/HBoxContainer/Avatar
@onready var nick_label = $BottomBar/HBoxContainer/MarginContainer/HBoxContainer/Nick

@onready var me_request = $BottomBar/HBoxContainer/MarginContainer/HBoxContainer/Avatar/me
@onready var profile_request = $BottomBar/HBoxContainer/MarginContainer/HBoxContainer/Avatar/profile
@onready var image_request = $BottomBar/HBoxContainer/MarginContainer/HBoxContainer/Avatar/image

var target_pos := Vector2.ZERO
var authIsOpened := false
var tween: Tween
var global_profile_id := 0

var closed_pos := Vector2.ZERO
var open_offset := Vector2(0, -30)

const PARALLAX_STRENGTH := -0.02
const PARALLAX_SPEED := 100.0

const AUTH_ANIM_TIME := 0.25
const AUTH_FADE_TIME := 0.2
const AUTH_HIDDEN_OFFSET := -30.0

func _ready() -> void:
	Config.load_config()

	var session = Config.config.get_value("user", "session")

	var is_logged = session != "null"

	login_button.visible = !is_logged
	avatar.visible = is_logged

	if is_logged:
		me_request.request(
			"%s/megame" % Config.HOST_SERVER,
			["Content-Type: application/json"],
			HTTPClient.METHOD_POST,
			JSON.stringify({
				"session": session
			})
		)

	await get_tree().process_frame

	closed_pos = auth.position

	auth.modulate.a = 0.0
	auth.visible = false

	GlobalUi._on_load_game_main_menu()



func _process(delta: float) -> void:
	var mouse = get_viewport().get_mouse_position()
	var center = get_viewport().size * 0.5

	target_pos = (mouse - center) * PARALLAX_STRENGTH

	background.position = background.position.lerp(
		target_pos,
		PARALLAX_SPEED * delta
	)


func AuthContainerUsing() -> void:
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	if authIsOpened:
		_open_auth()
	else:
		_close_auth()

func onLoginMain() -> void:
	$BottomBar/HBoxContainer/MarginContainer/Login.visible = false
	$AuthContainer.visible = false
	$BottomBar/HBoxContainer/MarginContainer/HBoxContainer.visible = true
	var session = Config.config.get_value("user", "session")
	me_request.request(
				"%s/megame" % Config.HOST_SERVER,
				["Content-Type: application/json"],
				HTTPClient.METHOD_POST,
				JSON.stringify({
					"session": session
				})
			)

func _open_auth() -> void:
	auth.visible = true

	auth.modulate.a = 0.0
	auth.position = closed_pos
	auth.position.y += AUTH_HIDDEN_OFFSET

	tween.set_parallel(true)

	tween.tween_property(
		auth,
		"position:y",
		closed_pos.y,
		AUTH_ANIM_TIME
	)

	tween.tween_property(
		auth,
		"modulate:a",
		1.0,
		AUTH_FADE_TIME
	)


func _close_auth() -> void:
	tween.set_parallel(true)

	tween.tween_property(
		auth,
		"position:y",
		closed_pos.y + AUTH_HIDDEN_OFFSET,
		AUTH_ANIM_TIME
	)

	tween.tween_property(
		auth,
		"modulate:a",
		0.0,
		AUTH_FADE_TIME
	)

	tween.chain().tween_callback(func():
		auth.visible = false
		auth.position = closed_pos
	)


func _on_login_pressed() -> void:
	authIsOpened = !authIsOpened
	AuthContainerUsing()


func _on_me_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	if response_code != 200:
		return

	var data = JSON.parse_string(body.get_string_from_utf8())

	global_profile_id = int(data["profile_id"])

	profile_request.request(
		"%s/profile?id=%s" % [
			Config.HOST_SERVER,
			data["profile_id"]
		]
	)


func get_image_url(path: String) -> String:
	if path.begins_with("http://") or path.begins_with("https://"):
		return path

	return "%s/%s" % [Config.HOST_SERVER, path]


func _on_profile_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	if response_code != 200:
		return

	var data = JSON.parse_string(body.get_string_from_utf8())

	data["avatar_url"] = str(data["avatar_url"]).replace("\\", "/")

	print(data)

	nick_label.text = data["username"]
	nick_label.visible = true

	image_request.request(
		get_image_url(data["avatar_url"])
	)


func _on_image_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	if response_code != 200:
		return

	var image = Image.new()

	var error = image.load_jpg_from_buffer(body)

	if error != OK:
		error = image.load_png_from_buffer(body)

	if error != OK:
		return

	var texture = ImageTexture.create_from_image(image)

	avatar.texture = texture
	avatar.modulate = Color.WHITE


func _on_avatar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			OS.shell_open(
				"%s/profile?id=%d" % [
					Config.HOST_WEBSITE,
					global_profile_id
				]
			)
