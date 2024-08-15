class_name EnemyAttackHandler extends Node2D

@export var enemy_node : EnemyEntity
@export_group("Internal Nodes")
@export var attack_timer : Timer

const ENEMY_BULLET = preload("res://Nodes/Entities/Enemies/EnemyComponents/enemy_bullet.tscn")

func _ready() -> void:
	attack_timer.timeout.connect(_try_attack)
	attack_timer.wait_time = enemy_node.attack_cooldown
	
	attack_timer.start()


func _try_attack() -> void:
	if enemy_node.has_target == true:
		if enemy_node.structure_target:
			_fire(enemy_node.structure_target.global_position - Vector2(0.0, 16.0))
		else:
			_fire(enemy_node.player_ref.global_position - Vector2(0.0, 8.0))
	
	attack_timer.start()


func _fire(target : Vector2) -> void:
	var new_bullet : EnemyBullet = ENEMY_BULLET.instantiate() as EnemyBullet
	add_child(new_bullet)
	new_bullet.global_position = global_position
	
	new_bullet.dir = global_position.direction_to(target)
	new_bullet.dmg = round(enemy_node.base_damage * 0.75)
	
