extends Node2D

enum GameState {BINDING_INPUT, PLAYING, LEVEL_WON}
var current_state = GameState.BINDING_INPUT

@export var level_1_config: CircleConfig
@onready var circle_renderer = $CircleRenderer
@onready var message_label = $CanvasLayer/MessageLabel

var current_action_name: String = "circle_1"

func _ready() -> void:
	message_label.text = "Press any key to assign to Circle 1"
	
	circle_renderer.circle_completed.connect(_on_level_won)
	circle_renderer.hit_registered.connect(_on_hit)
	circle_renderer.miss_registered.connect(_on_miss)

func _input(event: InputEvent):
	if current_state == GameState.BINDING_INPUT:
		if event is InputEventKey and event.pressed:
			assign_input(event)
			start_level()

func assign_input(event: InputEventKey):
	if not InputMap.has_action(current_action_name):
		InputMap.add_action(current_action_name)
	
	InputMap.action_add_event(current_action_name, event)
	
	get_viewport().set_input_as_handled()
	
	var key_name = OS.get_keycode_string(event.physical_keycode)
	message_label.text = "Assigned: " + key_name + "\nSmash 'em!"

func start_level():
	current_state = GameState.PLAYING
	circle_renderer.setup(level_1_config, current_action_name)
	
func _on_hit(total_hits: int):
	message_label.text = "Hit! (" + str(total_hits) + "/" + str(level_1_config.required_hits) + ")"
	
func _on_miss():
	message_label.text = "Miss!"

func _on_level_won():
	current_state = GameState.LEVEL_WON
	message_label.text = "Level Complete!"
	circle_renderer.set_process(false)
