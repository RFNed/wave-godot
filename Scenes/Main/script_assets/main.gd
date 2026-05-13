extends Control

@onready var clock = $Label
@onready var background = $background
var target_pos := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(3.0).timeout
	GlobalUi.add_notify("123")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse = get_viewport().get_mouse_position()
	var center = Vector2(get_viewport().size) * 0.5

	target_pos = (mouse - center) * -0.02

	background.position = background.position.lerp(target_pos, 100.0 * delta)
