@tool class_name AnimatableCannon extends Sprite2D

@export_group("Internal Nodes")
@export var turret : PlayerTurret
@export var cannon_light : PointLight2D
@export_group("Cannon Parameters")
@export_range(0.0, 1.0, 0.1) var cannon_direction : float = 0.5
@export var turn_speed : float = 0.75
@export var cannon_light_positions : Array[Vector2]


func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if is_instance_valid(turret.current_target):
			var direction_to_entity := turret.global_position.direction_to(turret.current_target.global_position)
			var magnitude : float = (direction_to_entity.dot(Vector2.RIGHT) + 1.0) * 0.5
			
			cannon_direction = lerpf(cannon_direction, magnitude, turn_speed * delta)
			_rotate_cannon()
	else:
		_rotate_cannon()


func _rotate_cannon() -> void:
	var min_frame : int = 0
	var max_frame : int = vframes - 1
	var cur_frame : int = round(lerp(max_frame, min_frame, cannon_direction))
	
	frame = cur_frame
	if cannon_light:
		cannon_light.position = cannon_light_positions[cur_frame]
