class_name PlayerHurtbox extends Area2D

@export var player_node : PlayerEntity

func _on_body_entered(body: Node2D) -> void:
	var dmg : int
	
	if body is EnemyEntity:
		dmg = body.base_damage
		
		player_node._take_damage(dmg)
		player_node._take_knockback(body.global_position.direction_to(player_node.global_position).x)
