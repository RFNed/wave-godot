extends VideoStreamPlayer

var canPlay = true

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if !self.is_playing() and canPlay:
		if GlobalUi.NOW_PLAY.has("video"):
			var video_load = load(GlobalUi.NOW_PLAY['video'])
			var stream = FFmpegVideoStream.new()
			stream.file = GlobalUi.NOW_PLAY['video']
			self.stream = stream
			self.play()
			self.stream_position = GlobalUi.player.get_playback_position()
			await get_tree().create_timer(1.0).timeout
			var tween = create_tween()
			tween.tween_property(self, "modulate:a", 1.0, 1.5).set_ease(Tween.EASE_IN)


func _on_finished() -> void:
	canPlay = false
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 2.5)
	await get_tree().create_timer(3.0).timeout
	canPlay = true
	self.stop()
