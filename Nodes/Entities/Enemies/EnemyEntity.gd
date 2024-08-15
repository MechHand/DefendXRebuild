class_name EnemyEntity extends GameEntity


@export_group("Enemy Behaviour")
@export var enemy_behaviour : EnemyBehaviour
@export var structure_detection : Area2D
@export_group("Enemy Level")
@export var enemy_level : int = 1
@export var enemy_level_color_mod : Array[Color] = [Color.WHITE, Color.GREEN, Color.YELLOW, Color.CORAL, Color.CADET_BLUE, Color.PURPLE]
@export var components_to_drop : int = 1
@export_group("Internal Nodes")
@export var sprite_node : Sprite2D

var is_valid_to_combat : bool = false

var player_ref : PlayerEntity
var has_target : bool = false
var structure_target : GameStructure

signal enemy_defeated

func _ready() -> void:
	structure_detection.body_entered.connect(_entity_detected)
	structure_detection.area_entered.connect(_entity_detected)
	
	structure_detection.body_exited.connect(_entity_lost)
	structure_detection.area_exited.connect(_entity_lost)
	
	_prepare_to_combat()


func _take_damage(dmg : int) -> void:
	current_health = clampi(current_health - dmg, 0, max_health)
	
	damage_taken.emit()
	velocity.x = 0.0
	
	if current_health <= 0:
		VfxSpawner._spawn_explosion(global_position)
		
		player_ref.ComponentAmount += components_to_drop
		player_ref.got_component.emit()
		enemy_defeated.emit()
		
		queue_free()


func _set_level_mod() -> void:
	base_damage *= enemy_level
	max_health *= enemy_level
	current_health = max_health
	
	var mod_index : int = enemy_level - 1
	if mod_index > enemy_level_color_mod.size() - 1:
		mod_index = enemy_level_color_mod.size() - 1
	sprite_node.self_modulate = enemy_level_color_mod[mod_index]


func _physics_process(delta: float) -> void:
	if enemy_behaviour:
		enemy_behaviour.execute_behaviour(delta)


func _entity_detected(entity : Node2D) -> void:
	if entity.get_parent() is GameStructure:
		var turret : GameStructure = entity.get_parent() as GameStructure
		if turret.current_state == GameStructure.State.Working:
			structure_target = turret
			structure_target._was_ruined.connect(_entity_lost.bind(structure_target))
			
			has_target = true
	elif entity is PlayerEntity:
		has_target = true


func _entity_lost(entity : Node2D) -> void:
	if entity is GameStructure:
		if entity.current_state == GameStructure.State.Ruined:
			structure_target = null
			has_target = false
	elif entity is PlayerEntity:
		has_target = false


## HACK : The turret will not spawn-target the enemy.
func _prepare_to_combat() -> void:
	await get_tree().create_timer(0.5).timeout
	
	is_valid_to_combat = true
