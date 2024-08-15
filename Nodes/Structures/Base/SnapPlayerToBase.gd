class_name SnapPlayerToBase extends Node2D

@export var player_node : PlayerEntity


func _ready() -> void:
	player_node.player_sprite.modulate.a = 0.0
	

func _snap_player() -> void:
	player_node.global_position = global_position

func _show_player() -> void:
	player_node.player_sprite.modulate.a = 1.0
