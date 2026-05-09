extends Control

@onready var showGradient = $ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_wake_up()

func _on_wake_up() -> void:
	var tween = create_tween()
	tween.tween_property(showGradient, "modulate:a", 0.0, 1.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
