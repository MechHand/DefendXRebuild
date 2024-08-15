class_name TurretAttackEffect extends Node2D

@onready var attack_anim: AnimationPlayer = $AttackAnim as AnimationPlayer


func _play_effect(target_pos : Vector2) -> void:
	look_at(target_pos)
	
	VfxSpawner._spawn_hit_impact(target_pos, modulate)
	attack_anim.play(&"Attack")
