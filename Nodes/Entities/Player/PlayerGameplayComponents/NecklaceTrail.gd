class_name NecklaceTrail extends Node2D

@export_group("Nodes")
@export var player : PlayerEntity
@export var trail : Line2D
@export_group("Trail Parameters")
@export var wind_intensity : float = 0.5
@export var velocity_lerp : float = 0.25
@export var influence_curve : Curve
@export var wind_curve : Curve

var inverse_velocity : Vector2 = Vector2.LEFT
var wind_delta : float = 0.0

const TRAIL_INTERVAL : float = 16

func _physics_process(delta: float) -> void:
	wind_delta += delta
	if wind_delta > 1.0:
		wind_delta = 0.0
	
	var wind_distortion : float = wind_curve.sample(wind_delta) * wind_intensity
	
	if abs(player.velocity.x) > 0.1:
		inverse_velocity = lerp(inverse_velocity, -player.velocity.normalized(), velocity_lerp)
	else:
		inverse_velocity = lerp(inverse_velocity, Vector2(inverse_velocity.x * 0.75, 0.5), velocity_lerp * 0.5)
	
	for i in trail.get_point_count():
		var trail_ratio : float = inverse_lerp(0, trail.get_point_count(), i)
		var influence : float = influence_curve.sample(trail_ratio)
		
		trail.set_point_position(i, (Vector2(inverse_velocity.x, inverse_velocity.y + (wind_distortion * (1.0 - influence))) * TRAIL_INTERVAL) * (influence))
