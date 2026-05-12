extends Button

@onready var fill = $ColorRect

var tween

func _ready() -> void:
	await get_tree().process_frame
	pivot_offset = size / 2
	fill.size.y = 0




func animate_hover(state):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	if state:
		$Label.modulate.a = 1.0
		tween.tween_property(fill, "size:y", size.y, 0.15)
	else:
		tween.tween_property($Label, "modulate:a", 0.0, 0.25)
		tween.tween_property(fill, "size:y", 0, 0.15)


func _on_mouse_entered() -> void:
	
	animate_hover(true)


func _on_mouse_exited() -> void:
	animate_hover(false)
