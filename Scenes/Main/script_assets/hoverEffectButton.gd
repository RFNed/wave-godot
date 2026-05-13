extends Button

var tween
var target_height = 0.0

func _ready() -> void:
	await get_tree().process_frame
	target_height = size.y


func _process(delta: float) -> void:
	pass

func animation(state):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	if state:
		$enteredText.modulate.a = 1.0
		tween.tween_property($enteredColor, "size:y", size.y, 0.15)
	else:
		tween.tween_property($enteredText, "modulate:a", 0.0, 0.25)
		tween.tween_property($enteredColor, "size:y", 0, 0.15)


func _on_mouse_entered() -> void:
	animation(true)


func _on_mouse_exited() -> void:
	animation(false)
