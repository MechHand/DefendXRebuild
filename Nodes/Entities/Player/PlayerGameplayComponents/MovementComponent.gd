class_name MovementComponent extends Node

@export var gravity : float = 360.0
@export var player : PlayerEntity

var can_jump : bool = true
@onready var jump_remaining_time : float = player.max_jump_time

func _physics_process(delta: float) -> void:
	var walk_axis : float = Input.get_axis(&"walk_left", &"walk_right")
	var jump_input : float = Input.is_action_pressed(&"jump")
	
	if is_zero_approx(player.knockback_velocity.x):
		if walk_axis:
			player.velocity.x = move_toward(player.velocity.x, player.base_move_speed * walk_axis, player.base_move_speed * player.speed_acel)
		else:
			player.velocity.x = move_toward(player.velocity.x, 0.0, player.base_move_speed * player.speed_damp)
		
		if can_jump == true or jump_remaining_time > 0.0:
			if jump_input:
				jump_remaining_time -= delta
				player.velocity.y = player.jump_strength
			else:
				jump_remaining_time = 0.0
	else:
		player.velocity = Vector2(player.knockback_velocity)
		player.knockback_velocity.x = move_toward(player.knockback_velocity.x, 0.0, (player.base_move_speed * 2.0) * delta)
		player.knockback_velocity.y += gravity * delta
	
	if player.is_on_floor():
		can_jump = true
		jump_remaining_time = player.max_jump_time
		
	else:
		can_jump = false
		player.velocity.y += gravity * delta
	
	if player.game_system.game_started == true:
		player.move_and_slide()
