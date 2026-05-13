extends CanvasLayer

@onready var notifications = $NotifyManager
var NOTIFY_SOUND = preload("res://Assets/notify_bell.ogg")

func add_notify(text):
	var wrapper = PanelContainer.new()
	var audio = AudioStreamPlayer.new()
	audio.stream = NOTIFY_SOUND
	audio.autoplay = true
	var style_wrapper = StyleBoxFlat.new()
	style_wrapper.bg_color = Color.TRANSPARENT
	
	wrapper.add_theme_stylebox_override("panel", style_wrapper)
	
	wrapper.custom_minimum_size = Vector2(241, 50)

	var label = Label.new()

	label.text = text
	label.position = Vector2(0, 0)

	label.add_theme_font_size_override("font_size", 20)

	label.modulate.a = 0.0

	var style = StyleBoxFlat.new()
	style.bg_color = Color("8f8f8f36")

	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 0
	style.expand_margin_left = 30
	style.expand_margin_top = 10
	style.expand_margin_bottom = 10
	style.expand_margin_right = 100
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_stylebox_override("normal", style)
	wrapper.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	wrapper.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	wrapper.add_child(label)
	wrapper.add_child(audio)
	notifications.add_child(wrapper)

	var tween = create_tween()

	tween.tween_property(label, "modulate:a", 1.0, 0.25)

	await get_tree().create_timer(3).timeout

	tween = create_tween()
	tween.set_parallel(true)


	tween.tween_property(wrapper, "position:x", 300, 0.45).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(label, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_IN_OUT)

	await tween.finished

	wrapper.queue_free()
