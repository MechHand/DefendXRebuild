extends AnimationPlayer

var is_walking : bool
var is_jumping : bool
var is_falling : bool
var is_shooting : bool
var is_taking_dmg : bool

@export var player : PlayerEntity
@export var player_spritesheet : Sprite2D
@export var player_light_aura : Light2D
@export var hand_pivot : Node2D

@onready var jump_audio: AudioStreamPlayer = $"../JumpAudio"
@onready var ground_audio: AudioStreamPlayer = $"../GroundAudio"
@onready var dmg_audio: AudioStreamPlayer = $"../DmgAudio"
@onready var player_atk: AudioStreamPlayer = $"../PlayerAtk"

var can_ground_audio : bool = true
var can_jump_audio : bool = true

func _process(delta: float) -> void:
	if player.inv_timer:
		if player.inv_timer.is_stopped() and player.current_health > 0:
			is_taking_dmg = false
		else:
			is_taking_dmg = true
	
	if DayLightSystem.world_time > 0.5:
		player_light_aura.enabled = true
		player_light_aura.energy = DayLightSystem.world_time * 2.0
	else:
		player_light_aura.enabled = false
	
	if abs(player.velocity.x) > 1.0 and not is_taking_dmg:
		is_walking = true
		
		if player.velocity.x > 0.0:
			player_spritesheet.flip_h = false
			hand_pivot.scale.x = 1.0
		else:
			player_spritesheet.flip_h = true
			hand_pivot.scale.x = -1.0
	else:
		is_walking = false
	
	if player.is_on_floor():
		is_falling = false
		is_jumping = false
	else:
		if player.velocity.y >= 0.0:
			is_falling = true
			is_jumping = false
		else:
			is_falling = false
			is_jumping = true
	
	_handle_anim()


func _handle_anim() -> void:
	if not is_taking_dmg:
		if player.is_on_floor():
			if is_walking == true:
				play(&"Walk")
			else:
				play(&"Idle")
		else:
			if is_jumping == true:
				play(&"Jumping")
			else:
				play(&"Falling")
	else:
		play(&"OnDamage")
