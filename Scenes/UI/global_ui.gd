extends CanvasLayer

@onready var notifications = $NotifyManager
var NOTIFY_SOUND = preload("res://Assets/notify_bell.ogg")
var NOW_PLAY = {}
var exiting = false
var MAPS = []
const BEATMAPS_FOLDER = "user://beatmaps"
var player = AudioStreamPlayer.new()

func _on_audio_background_finished():
	if MAPS.is_empty():
		return
	var beatmap = MAPS.pick_random()
	
	if MAPS.size() > 1:
		while beatmap == NOW_PLAY:
			beatmap = MAPS.pick_random()
	
	NOW_PLAY = beatmap
	await get_tree().process_frame
	
	player.stop()
	player.stream = beatmap["stream"]
	player.volume_db = -80
	player.play()
	
	var tween = create_tween()
	tween.tween_property(player, "volume_db", 0, 0.05)

func _ready() -> void:
	get_tree().root.close_requested.connect(_byebye)

func _on_load_game_main_menu() -> void:
	player.finished.connect(_on_audio_background_finished)
	randomize()

	if !DirAccess.dir_exists_absolute(BEATMAPS_FOLDER):
		DirAccess.make_dir_recursive_absolute(BEATMAPS_FOLDER)
		return

	var dir = DirAccess.open(BEATMAPS_FOLDER)
	if dir == null:
		return

	dir.list_dir_begin()
	var name = dir.get_next()

	while name != "":
		if dir.current_is_dir():
			var cfg_path = "%s/%s/map.cfg" % [BEATMAPS_FOLDER, name]
			if FileAccess.file_exists(cfg_path):
				var audio_path = "%s/%s/audio.wav" % [BEATMAPS_FOLDER, name]
				var audio = FileAccess.open(audio_path, FileAccess.READ)
				if audio:
					var stream = AudioStreamWAV.new()
					stream.format = AudioStreamWAV.FORMAT_16_BITS
					stream.mix_rate = 44100
					stream.stereo = true
					stream.data = audio.get_buffer(audio.get_length())
					var data_beatmap = {"stream": stream}
					if FileAccess.file_exists("%s/%s/video.webm" % [BEATMAPS_FOLDER, name]):
						data_beatmap['video'] = "%s/%s/video.webm" % [BEATMAPS_FOLDER, name]
					add_notify("Registered: %s" % data_beatmap)
					MAPS.append(data_beatmap)
		name = dir.get_next()

	dir.list_dir_end()
	if MAPS.size() > 0:
		add_child(player)
		var beatmap = MAPS.pick_random()
		NOW_PLAY = beatmap
		await get_tree().process_frame
		player.stream = beatmap["stream"]
		player.volume_db = -80
		player.play()
		var tween = create_tween()
		tween.tween_property(player, "volume_db", 0, 0.5)



func get_main_data() -> Dictionary:
	return {}

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

func _byebye() -> void:
	if exiting: 
		return
	exiting = true
	add_notify("! > Render fade")
	var tween = create_tween()
	var fade = $ColorRect
	
	fade.visible = true
	tween.set_parallel(true)
	tween.tween_property(fade, "modulate:a", 1.0, 1.5).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(player, "volume_db", -80.0, 2.5)
	await tween.finished
	await get_tree().physics_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_tree().quit()
