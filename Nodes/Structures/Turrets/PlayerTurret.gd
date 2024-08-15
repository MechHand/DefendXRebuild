class_name PlayerTurret extends GameStructure


@export_group("Turret Parameters")
@export var max_targets : int = 1
@export var time_to_repair : float = 0.5
@export var fire_color : Color = Color.GREEN
@export_group("Turret Nodes")
@export var turret_attack : TurretAttackEffect
@export var turret_sprite : Sprite2D
@export var turret_range_area : Area2D
@export var repair_area : Area2D
@export var smoke_particles : GPUParticles2D
@export var attack_timer : Timer
@export var repair_hud : ResourceHud
@export var resource_needed : ResourceNeeded

var targets : Array[EnemyEntity]
var current_target : GameEntity

var player_ref : PlayerEntity
var can_be_repaired : bool = false
var repair_ratio : float = 0.0


func _ready() -> void:
	attack_timer.wait_time = attack_cooldown
	turret_attack.modulate = fire_color
	
	turret_range_area.body_entered.connect(_new_target_entered)
	attack_timer.timeout.connect(_attack)
	
	repair_area.body_entered.connect(_player_entered)
	repair_area.body_exited.connect(_player_exited)
	
	resource_needed._update_info(points_to_repair, material_to_repair)
	
	_was_ruined.connect(_set_sprite)
	
	_set_sprite()
	
	_snap_to_floor()


func _take_damage(amount : int) -> void:
	super(amount)
	
	if current_state == State.Ruined:
		targets.clear()
		can_be_repaired = true
		repair_ratio = 0.0


func _attack() -> void:
	if current_state == State.Working:
		if targets.size() >= 1:
			for target in clamp(targets.size() - 1, 1, max_targets):
				if is_instance_valid(targets[target]):
					if targets[target].is_valid_to_combat == true:
						if turret_attack:
							turret_attack._play_effect(targets[target].global_position)
						targets[target]._take_damage(attack_damage)
				else:
					targets.pop_at(target)
		
		await get_tree().create_timer(0.1).timeout
		
		if targets.size() >= 1:
			for target in clamp(targets.size() - 1, 1, max_targets):
				if not is_instance_valid(targets[target]):
					targets.pop_at(target)
			
			attack_timer.wait_time = attack_cooldown
			attack_timer.start()


func _physics_process(delta: float) -> void:
	_handle_repair(delta)


func _new_target_entered(new_target : Node2D) -> void:
	if current_state == State.Working:
		if targets.size() < max_targets:
			if new_target is EnemyEntity:
				if new_target.is_valid_to_combat == true:
					targets.append(new_target)
					current_target = new_target as EnemyEntity
					
					if attack_timer.is_stopped():
						attack_timer.start()


func _player_entered(player : Node2D) -> void:
	if current_state == State.Ruined:
		can_be_repaired = true
		if player is PlayerEntity:
			player_ref = player
		resource_needed._update_allowed(_get_can_be_repaired())
		repair_hud._show_up()


func _player_exited(player : Node2D) -> void:
	if current_state == State.Ruined:
		can_be_repaired = false
		repair_hud._hide_off()


func _handle_repair(delta : float) -> void:
	if current_state == State.Ruined and can_be_repaired == true:
		var repair_input := Input.is_action_pressed(&"collect")
		
		if repair_input and _get_can_be_repaired():
			repair_ratio += delta / time_to_repair
		else:
			repair_ratio = 0.0
		
		repair_hud._update_progress(repair_ratio)
		
		if repair_ratio >= 1.0:
			current_state = State.Working
			current_hit_points = hit_points
			
			if player_ref:
				player_ref._spend_player_resource(points_to_repair, material_to_repair)
			
			_was_repaired.emit(self)
			repair_hud._hide_off()
			_set_sprite()
			can_be_repaired = false


func _set_sprite() -> void:
	match current_state:
		State.Ruined:
			smoke_particles.emitting = true
			turret_sprite.frame = 1
			
			for child in turret_sprite.get_children():
				if child is Node2D:
					(child as Node2D).hide()
		State.Working:
			smoke_particles.emitting = false
			turret_sprite.frame = 0
			
			for child in turret_sprite.get_children():
				if child is Node2D:
					(child as Node2D).show()


func _get_player_resources(spend_resource : bool = false) -> int:
	match material_to_repair:
		Materials.Wood:
			return PlayerEntity.WoodAmount
		Materials.Metal:
			return PlayerEntity.MetalAmount
		Materials.Component:
			return PlayerEntity.ComponentAmount
		_:
			print("Invalid Material")
			return 0

func _get_can_be_repaired() -> bool:
	var resources : int = _get_player_resources()
	
	if resources >= points_to_repair:
		return true
	else:
		return false
