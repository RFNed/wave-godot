extends MarginContainer


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	$VBoxContainer/date.text = Time.get_date_string_from_system()
	$VBoxContainer/clock.text = Time.get_time_string_from_system()
