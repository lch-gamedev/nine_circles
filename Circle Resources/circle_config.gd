class_name CircleConfig extends Resource

@export var radius: float = 100.0
@export var cursor_speed: float = 2.0 # think radians per second
@export var hit_window: float = 0.2 # margin of error (in radians)
@export var required_hits: int = 4

@export_group("Target Spawning")
@export var spawn_angles: Array[float] = [0.0, PI/2, PI, 3*PI/2]
@export var max_targets_rendered: int = 3
@export var possible_targets: Array[TargetConfig]
