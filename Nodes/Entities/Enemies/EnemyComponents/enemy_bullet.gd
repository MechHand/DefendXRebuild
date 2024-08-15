class_name EnemyBullet extends Node2D

var dir : Vector2 = Vector2.RIGHT
var dmg : int = 1
var speed : float = 95.0


func _physics_process(delta: float) -> void:
	translate((dir * speed) * delta)


func _verify_collision(body: Node2D) -> void:
	if body is PlayerEntity:
		body._take_damage(dmg)
		VfxSpawner._spawn_hit_impact(global_position, Color.YELLOW)
	elif body.get_parent() is GameStructure:
		var turret : GameStructure = body.get_parent() as GameStructure
		
		if turret.current_state == GameStructure.State.Working:
			turret._take_damage(dmg)
			VfxSpawner._spawn_hit_impact(global_position, Color.RED)
	elif body is TileMap:
		VfxSpawner._spawn_hit_impact(global_position, Color.ORANGE)
	
	queue_free()


func _on_auto_destroy_timer_timeout() -> void:
	print(name, " was autodestroyed at ", global_position)
	queue_free()
