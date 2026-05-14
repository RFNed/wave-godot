extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_register_pressed() -> void:
	OS.shell_open("http://127.0.0.6:5173/register")
	GlobalUi.add_notify("Нажата кнопка регистрация")


func _on_login_pressed() -> void:
	if ($VBoxContainer/MarginContainer/VBoxContainer/Login.text == "") or ($VBoxContainer/MarginContainer/VBoxContainer/Password.text == ""):
		GlobalUi.add_notify("Введите данные!")
		return
	var body = {
		"nickname": $VBoxContainer/MarginContainer/VBoxContainer/Login.text,
		"password": $VBoxContainer/MarginContainer/VBoxContainer/Password.text
	}
	$VBoxContainer/HBoxContainer/Login/RequestAuth.request("http://127.0.0.6:8000/auth", ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify(body))


func _on_request_auth_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var data = JSON.parse_string(body.get_string_from_utf8())
	if (response_code == 200 and data['result'] == "granted"):
		GlobalUi.add_notify("Правильно")
		Config.config.set_value("user", "session", str(data['session_id']))
		Config.config.save(Config.USER_CONFIG)
		get_parent().onLoginMain()
	else:
		GlobalUi.add_notify("Неверный логин/пароль")
