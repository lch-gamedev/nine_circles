extends Node

enum GameState {BINDING_OVERLAY, BINDING_INPUT, PLAYING, LEVEL_WON, GAME_OVER}
var current_state = GameState.BINDING_OVERLAY

@export var circle_scene: PackedScene
@export var level_configs: Array[CircleConfig]

@onready var message_label = $CanvasLayer/MessageLabel
@onready var transition_menu = $CanvasLayer/TransitionMenu

var current_level_index: int = 0
var active_renderers: Array[Node2D] = []
var completed_circles_this_level: int = 0

func _ready() -> void:
	transition_menu.hide()
	transition_menu.next_level_requested.connect(_on_next_level_requested)
	
	if not InputMap.has_action("show_overlay"):
		InputMap.add_action("show_overlay")
	else:
		InputMap.action_erase_events("show_overlay")
		
	message_label.text = "Choose your OVERLAY key..."

func prepare_level():
	completed_circles_this_level = 0
	
	current_state = GameState.BINDING_INPUT
	if current_level_index < level_configs.size():
		
		var new_renderer = circle_scene.instantiate()
		add_child(new_renderer)
		active_renderers.append(new_renderer)
		
		new_renderer.circle_completed.connect(_on_any_circle_completed)
		
		reposition_circles()
		message_label.text = "Level " + str(current_level_index + 1) + "\nPress a NEW key to assign to the new circle."
	else:
		current_state = GameState.GAME_OVER
		message_label.text = "You escaped and freed all those poor lost souls!"

func _input(event: InputEvent):
	
	if event is InputEventKey and event.pressed:
	
		if current_state == GameState.BINDING_OVERLAY:
			assign_overlay_input(event)
				
		elif current_state == GameState.BINDING_INPUT:
			var new_action = "circle_" + str(current_level_index)
				
			var already_bound = false
			for action in InputMap.get_actions():
				if (action.begins_with("circle_") or action == "show_overlay"): 
					if InputMap.action_has_event(action, event):
						already_bound = true
						break
						
			if not already_bound:
				assign_input(event, new_action)
				start_level(new_action)
			else:
				message_label.text = "Key already in use! Pick another..."

func assign_input(event: InputEventKey, action_name: String):
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	InputMap.action_add_event(action_name, event)
	get_viewport().set_input_as_handled()

func start_level(new_action_name: String):
	current_state = GameState.PLAYING
	message_label.text = "Destroy the denizens of hell!"
	
	var newest_renderer = active_renderers.back()
	newest_renderer.setup(level_configs[current_level_index], new_action_name)
	
	for renderer in active_renderers:
		renderer.set_process(true)
		renderer.hits_achieved = 0
	

func _on_any_circle_completed():
	completed_circles_this_level += 1
	if completed_circles_this_level >= active_renderers.size():
		level_won()

func level_won():
	current_state = GameState.LEVEL_WON
	message_label.text = "Level Completed!"
	
	for renderer in active_renderers:
		renderer.set_process(false)
	transition_menu.show()

func _on_next_level_requested():
	current_level_index += 1
	prepare_level()

func reposition_circles():
	var screen_size = get_viewport().get_visible_rect().size
	var cols = ceil(sqrt(active_renderers.size()))
	if cols == 0: return
	var rows = ceil(float(active_renderers.size()) / cols)
	
	var cell_width = screen_size.x / cols
	var cell_height = screen_size.y / rows
	
	for i in range(active_renderers.size()):
		var col = i % int(cols)
		var row = int (floor(float(i) / cols))
		
		var x = (col * cell_width) + (cell_width / 2.0)
		var y = (row * cell_height) + (cell_height / 2.0)
		
		active_renderers[i].position = Vector2(x, y)

func assign_overlay_input(event: InputEventKey):
	InputMap.action_add_event("show_overlay", event)
	get_viewport().set_input_as_handled()
	
	var key_name = OS.get_keycode_string(event.physical_keycode)
	print("Overlay bound to: ", key_name)
	prepare_level()
