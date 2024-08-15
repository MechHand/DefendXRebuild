class_name EnemyAnimationHandler extends Node


@export var enemy_node : EnemyEntity
@export var sprite_node : Sprite2D
@export var pivot_to_mirror : Node2D


func _physics_process(delta: float) -> void:
	if enemy_node.velocity.x:
		if enemy_node.velocity.x > 0.1:
			sprite_node.flip_h = false
			if pivot_to_mirror:
				pivot_to_mirror.scale.x = 1.0
		else:
			sprite_node.flip_h = true
			if pivot_to_mirror:
				pivot_to_mirror.scale.x = -1.0
	
	
