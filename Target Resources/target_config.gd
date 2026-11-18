class_name TargetConfig extends Resource

@export var radius: float = 20.0
@export var speed: float = 1.0
@export var direction: int = 1 # 1 is clockwise; -1 is anti-clockwise
@export var frames: SpriteFrames
@export var animation_name: String = "default"
@export var scale: Vector2 = Vector2(1, 1)

@export_group("Hit Effects")
@export var hit_sound: AudioStream
@export var death_animation_name: String = "death"
