class_name EnemyBehaviour extends Node2D

@export var enemy_node : EnemyEntity

var player_ref : PlayerEntity


func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group(&"Player")


func execute_behaviour(delta : float) -> void:
	pass
