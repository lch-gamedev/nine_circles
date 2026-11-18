extends Control

signal next_level_requested

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/Button.pressed.connect(_on_button_pressed)


func _on_button_pressed():
	next_level_requested.emit()
	hide()
