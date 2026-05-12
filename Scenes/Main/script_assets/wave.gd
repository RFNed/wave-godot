extends TextureRect

var tween
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	pivot_offset = size / 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mouse_entered() -> void:
	animate_hover(true)
	



func animate_hover(state):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	if state:
		tween.tween_property(self, "scale", Vector2(1.25, 1.25), 0.25)
		
	else:
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func animate_click():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.15)
	tween.tween_property(self, "scale", Vector2(1.25, 1.25), 0.1)

func _on_mouse_exited() -> void:
	animate_hover(false)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			OS.shell_open("http://127.0.0.6:5173")
			animate_click()
