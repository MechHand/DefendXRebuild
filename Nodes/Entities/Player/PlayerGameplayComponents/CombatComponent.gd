class_name PlayerCombatComponent extends Node

@export var player : PlayerEntity
@export var player_sprite : Sprite2D 
@export var bullet_pivot : Marker2D
@export var attack_timer : Timer

var player_dir : float = 1.0
var can_fire : bool = true

const PLAYER_BULLET = preload("res://Nodes/Bullets/PlayerBullet/player_bullet.tscn")


func _ready() -> void:
	attack_timer.wait_time = player.attack_cooldown


func _physics_process(delta: float) -> void:
	var fire_input : bool = Input.is_action_pressed("fire")
	
	if fire_input and can_fire:
		if player_sprite.is_flipped_h() == true:
			player_dir = -1.0
		else:
			player_dir = 1.0
		
		_fire()
		
		attack_timer.start()
		can_fire = false


func _fire() -> void:
	var new_bullet : PlayerBullet = PLAYER_BULLET.instantiate() as PlayerBullet
	player.game_system.add_child(new_bullet)
	
	new_bullet.global_position = bullet_pivot.global_position
	
	new_bullet.dir = Vector2(player_dir, 0.0)
	new_bullet.dmg = 1 + player.base_damage


func _on_attack_cooldown_timeout() -> void:
	attack_timer.wait_time = player.attack_cooldown
	can_fire = true
