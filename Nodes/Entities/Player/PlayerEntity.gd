class_name PlayerEntity extends GameEntity

@export_group("Internal Nodes")
@export var collection_particles : GPUParticles2D
@export var player_hud : PlayerHud
@export var camera_component : PlayerCameraComponent
@export var player_sprite : Sprite2D
@export_group("External Nodes")
@export var enemy_wave_spawner : EnemyWaveSpawner
@export var game_system : GameSystem

static var WoodAmount : int = 0
static var MetalAmount : int = 0
static var ComponentAmount : int = 0

signal got_wood
signal got_metal
signal got_component

var player_dead : bool = false

func _ready() -> void:
	attack_cooldown = 0.3
	
	var new_inv_timer : Timer = Timer.new()
	add_child(new_inv_timer)
	inv_timer = new_inv_timer
	inv_timer.one_shot = true
	inv_timer.wait_time = inv_time
	
	player_hud._update_life_bar(0)


func _take_damage(damage_amount : int) -> void:
	if player_dead == false:
		if inv_timer.is_stopped():
			current_health = clampi(current_health - damage_amount, 0, max_health)
			
			if current_health <= 0:
				camera_component._camera_shake(6, 6)
				ScreenEffects._play_game_over()
				player_dead = true
			else:
				camera_component._camera_shake()
			
			damage_taken.emit(damage_amount)
			inv_timer.start()


func _take_knockback(to_dir : float) -> void:
	var vertical_magnitude : float = jump_strength * 0.5
	
	knockback_magnitude = knockback_initial_velocity * to_dir
	
	knockback_velocity = Vector2(knockback_magnitude, vertical_magnitude)


func _spend_player_resource(amount : int, type : GameStructure.Materials) -> void:
	match type:
		GameStructure.Materials.Wood:
			WoodAmount = clampi(WoodAmount - amount, 0, WoodAmount)
			got_wood.emit()
		GameStructure.Materials.Metal:
			MetalAmount = clampi(MetalAmount - amount, 0, MetalAmount)
			got_metal.emit()
		GameStructure.Materials.Component:
			ComponentAmount = clampi(ComponentAmount - amount, 0, ComponentAmount)
			got_component.emit()
