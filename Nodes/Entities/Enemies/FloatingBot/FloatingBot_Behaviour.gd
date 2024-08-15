extends EnemyBehaviour

@export var ray_cast : RayCast2D

@export_group("Floating Parameters")
@export var up_speed : float = 20.0
@export var down_speed : float = 60.0
@export var horizontal_speed : float = 40.0


func execute_behaviour(delta : float) -> void:
	ray_cast.force_raycast_update()
	
	if ray_cast.is_colliding():
		if ray_cast.get_collider() is TileMap:
			
			enemy_node.velocity.y -= up_speed * delta
	else:
		enemy_node.velocity.y += down_speed * delta
	
	var dir_to_player : float
	if player_ref:
		dir_to_player = enemy_node.global_position.direction_to(player_ref.global_position).x
	else:
		dir_to_player = -1.0
	
	if enemy_node.has_target == false:
		enemy_node.velocity.x = move_toward(enemy_node.velocity.x, horizontal_speed * dir_to_player, horizontal_speed * 0.1)
	else:
		enemy_node.velocity.x = move_toward(enemy_node.velocity.x, 0.0, horizontal_speed * 0.33)
	
	enemy_node.move_and_slide()
