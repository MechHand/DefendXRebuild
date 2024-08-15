class_name WorldResource extends Node2D

enum MaterialType {Wood, Metal}
@export_group("Gameplay Parameters")
@export var material_type : MaterialType = MaterialType.Wood
@export var colect_min_amount : int = 2
@export var colect_max_amount : int = 8
@export var harvest_time : float = 5.0
@export_range(10.0, 60.0, 5.0,"or_greater", "suffix:seconds") var respawn_time : float = 1.0
@export var harverst_area : Area2D
@export var respawn_timer : Timer
@export_group("Visual Parameters")
@export var sprite_node : Sprite2D
@export var particle_node : GPUParticles2D
@export var light_node : PointLight2D
@export var resource_hud : ResourceHud
@export var collecting_effect : GPUParticles2D

var collection_ratio : float = 0.0

var can_be_collected : bool = false
var already_collected : bool = false

const COLLECTED_COLOR : Color = Color(0.0, 1.0, 1.0, 0.15)

signal _was_collected

var player_ref : PlayerEntity

func _ready() -> void:
	harverst_area.body_entered.connect(_entity_entered)
	harverst_area.body_exited.connect(_entity_exited)
	
	respawn_timer.wait_time = respawn_time
	respawn_timer.timeout.connect(_respawn)
	
	collecting_effect.emitting = false
	
	_snap_to_floor()
	_randomize_sprite()
	set_physics_process(false)


func _respawn() -> void:
	collection_ratio = 0.0
	already_collected = false
	sprite_node.modulate = Color.WHITE


func _physics_process(delta: float) -> void:
	if already_collected == false:
		var collect_input := Input.is_action_pressed(&"collect")
		
		if collect_input:
			collection_ratio += delta / harvest_time
			collecting_effect.emitting = true
		else:
			collection_ratio = 0.0
			collecting_effect.emitting = false
		
		sprite_node.modulate = lerp(COLLECTED_COLOR, Color.WHITE, 1.0 - collection_ratio)
		
		resource_hud._update_progress(collection_ratio)
		
		if collection_ratio >= 1.0:
			player_ref.collection_particles.emitting = true
			_give_resource()
			_was_collected.emit()
			resource_hud._hide_off()
			already_collected = true
			collecting_effect.emitting = false
			
			respawn_timer.wait_time = respawn_time
			respawn_timer.start()


func _give_resource() -> void:
	if player_ref:
		var amount : int = randi_range(colect_min_amount, colect_max_amount)
		
		match material_type:
			MaterialType.Wood:
				print("Player got ", amount, " woods.")
				player_ref.WoodAmount += amount
				player_ref.got_wood.emit()
			MaterialType.Metal:
				print("Player got ", amount, " metals.")
				player_ref.MetalAmount += amount
				player_ref.got_metal.emit()


func _entity_entered(entity : Node2D) -> void:
	if entity is PlayerEntity:
		player_ref = entity
		
		can_be_collected = true
		print(entity.name, " can collect ", name, ".")
		if already_collected == false:
			resource_hud._show_up()
		set_physics_process(true)

func _entity_exited(entity : Node2D) -> void:
	if entity is PlayerEntity:
		can_be_collected = false
		print(name, " cannot be colected.")
		collecting_effect.emitting = false
		if already_collected == false:
			resource_hud._hide_off()
		set_physics_process(false)


## Cria um raycast para detectar o chão, caso encontre, essa estrutura é reposicionada. Ao fim, o raycast é deletado para não ocupar espaço na memória.
func _snap_to_floor() -> void:
	await get_tree().create_timer(0.1).timeout
	
	var new_raycast : RayCast2D = RayCast2D.new()
	add_child(new_raycast)
	
	new_raycast.target_position = Vector2(0.0, 516.0)
	new_raycast.force_raycast_update()
	
	if new_raycast.is_colliding():
		var collider : Object = new_raycast.get_collider()
		print(name, " Is colliding with ", collider)
		
		if collider is TileMap:
			global_position = new_raycast.get_collision_point()
	else:
		print(name, " Is not colliding")
	
	new_raycast.queue_free()


func _randomize_sprite() -> void:
	await get_tree().create_timer(0.1).timeout
	
	if sprite_node:
		var random_bool : Array[bool] = [true, false]
		var frames : int = sprite_node.hframes * sprite_node.vframes
		var internal_seed : int = str(global_position.x, global_position.y).to_int()
		
		seed(internal_seed)
		sprite_node.frame = randi_range(0, frames - 1)
		print(randi_range(0, frames - 1))
		sprite_node.flip_h = random_bool.pick_random()
