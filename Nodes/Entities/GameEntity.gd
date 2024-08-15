class_name GameEntity extends CharacterBody2D


@export_group("Gameplay Parameters")
@export_subgroup("Combat")
@export var base_damage : int = 1
@export_range(0.005, 1.0, 0.005) var attack_cooldown : float = 0.5
@export_subgroup("Health")
@export var max_health : int = 10
@onready var current_health : int = max_health
@export_range(0.1, 1.0, 0.1) var inv_time : float = 0.5
@export_subgroup("Mobility")
@export var base_move_speed : float = 80.0
@export var speed_acel : float = 0.4
@export var speed_damp : float = 0.8
@export var jump_strength : float = -40.0
@export var max_jump_time : float = 1.25
@export var fall_speed : float = 80.0
@export var max_fall_speed : float = 256.0
@export_subgroup("Knockback")
@export var knockback_velocity : Vector2 = Vector2.ZERO
@export var knockback_initial_velocity : float = 150.0

var inv_timer : Timer

var attack_timer : Timer
var knockback_magnitude : float

signal damage_taken (amount : int)


func _take_damage(damage_amount : int) -> void:
	pass


func _take_knockback(to_dir : float) -> void:
	pass


func _initialize_timers() -> void:
	var new_inv_timer : Timer = Timer.new() 
	add_child(new_inv_timer)
	
	var new_attack_timer : Timer = Timer.new() 
	add_child(new_attack_timer)
	
	inv_timer = new_inv_timer
	attack_timer = new_attack_timer
