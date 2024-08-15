class_name PlayerBullet extends Node2D

var dir : Vector2 = Vector2.RIGHT
var dmg : int = 1
var speed : float = 120.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	translate((dir * speed) * delta)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is EnemyEntity:
		body._take_damage(dmg)
		VfxSpawner._spawn_hit_impact(global_position, Color.DEEP_SKY_BLUE)
	elif body is TileMap:
		VfxSpawner._spawn_hit_impact(global_position, Color.ORANGE)
	
	
	queue_free()


func _on_auto_destroy_timer_timeout() -> void:
	print(name, " was autodestroyed at ", global_position)
	queue_free()
