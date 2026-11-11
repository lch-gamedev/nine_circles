class_name CircleRenderer extends Node2D

var config: CircleConfig
var action_name: String = ""

var current_angle: float = 0.0
var hits_achieved: int = 0

var active_targets: Array[Dictionary] = []

signal circle_completed
signal hit_registered(total_hits:int)
signal miss_registered

func setup(new_config: CircleConfig, mapped_action: String):
	config = new_config
	action_name = mapped_action
	active_targets.clear()
	current_angle = 0.0
	hits_achieved = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if config == null or action_name == "": return
	
	current_angle = wrapf(current_angle + config.cursor_speed * delta, 0, TAU)
	
	for target in active_targets:
		var movement = target.data.speed * target.data.direction * delta
		target.angle = wrapf(target.angle + movement, 0, TAU)
		
	if active_targets.size() < config.max_targets_rendered and config.possible_targets.size() > 0:
		spawn_target()
	
	queue_redraw()

func spawn_target():
	var random_config = config.possible_targets.pick_random()
	var random_angle = config.spawn_angles.pick_random()
	active_targets.append({
		"angle": random_angle,
		"data": random_config
	})

func _input(event: InputEvent) -> void:
	if action_name != "" and event.is_action_pressed(action_name):
		check_hit()

func check_hit():
	for i in range(active_targets.size() -1, -1, -1):
		var target = active_targets[i]
		var diff = abs(angle_difference(current_angle, target.angle))
		
		if diff <= config.hit_window:
			hits_achieved += 1
			active_targets.remove_at(i)
			hit_registered.emit(hits_achieved)
			
			if hits_achieved >= config.required_hits:
				circle_completed.emit()
			return
	miss_registered.emit()

func _draw():
	if config == null: return
	
	draw_arc(Vector2.ZERO, config.radius, 0, TAU, 64, Color.DIM_GRAY, 2.0)
	
	for target in active_targets:
		var target_pos = Vector2.from_angle(target.angle) * config.radius
		draw_circle(target_pos, 8.0, target.data.color)
		
	
	var cursor_pos = Vector2.from_angle(current_angle) * config.radius
	draw_circle(cursor_pos, 10.0, Color.WHITE)
