extends CanvasLayer

@onready var notifications = $NotifyManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func add_notify(text):
	var label = Label.new()
	
	label.text = text
	
	notifications.add_child(label)
	
	await get_tree().create_timer(3).timeout
	label.queue_free()

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
