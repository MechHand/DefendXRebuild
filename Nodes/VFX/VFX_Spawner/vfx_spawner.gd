class_name VFXSpawner extends Node2D

const HIT_EFFECT = preload("res://Nodes/VFX/hit_effect.tscn")
const VFX_EXPLOSION = preload("res://Nodes/VFX/VFX_Explosion/VFX_Explosion.tscn")

var level_node : GameSystem


func _spawn_hit_impact(pos : Vector2, color : Color = Color.WHITE) -> void:
	if is_instance_valid(level_node):
		var new_hit : Node2D = HIT_EFFECT.instantiate() as Node2D
		level_node.add_child(new_hit)
		
		new_hit.global_position = pos
		new_hit.modulate = color


func _spawn_explosion(pos : Vector2, shake : bool = true) -> void:
	if is_instance_valid(level_node):
		var new_explosion : Node2D = VFX_EXPLOSION.instantiate() as Node2D
		level_node.add_child(new_explosion)
		
		new_explosion.global_position = pos
		
		if shake == true:
			level_node.player_node.camera_component._camera_shake(5, 5)
