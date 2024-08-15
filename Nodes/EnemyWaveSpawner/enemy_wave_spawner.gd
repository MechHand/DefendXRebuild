class_name EnemyWaveSpawner extends Node

static var EnemiesFile : Dictionary = {
	"FloatingBot" : preload("res://Nodes/Entities/Enemies/FloatingBot/enemy_floating_bot.tscn")
}

@export_group("Waves Data")
@export var waves : Array[WaveInfo]
@export var current_wave : int = 0
@export var interval_between_enemies : float = 1.25
@export var interval_to_boss : float = 5.0
@export_group("External Nodes")
@export var level_node : GameSystem
@export var procedural_map : ProceduralMapGenerator

@onready var wave_timer: Timer = $WaveTimer
@onready var spawn_interval: Timer = $SpawnInterval

var spawn_point : float = 0.0

var enemies_in_wave : int = 0

signal wave_completed 
signal wave_started

func _ready() -> void:
	enemies_in_wave = 0
	spawn_point = float((procedural_map.map_size * 8) - 8)
	
	await level_node._start_game
	_spawn_wave(0)


func _skip_await_timer() -> void:
	if not wave_timer.is_stopped():
		wave_timer.stop()
		wave_timer.timeout.emit()
		wave_started.emit()
	pass


func _spawn_wave(wave_index : int = 0) -> void:
	current_wave = wave_index
	
	wave_timer.wait_time = _get_time_to_start(wave_index)
	wave_timer.start()
	await wave_timer.timeout
	wave_started.emit()
	
	spawn_interval.wait_time = interval_between_enemies
	enemies_in_wave = _get_enemy_amount(wave_index) + 1
	print("Wave with ", enemies_in_wave, " enemies")
	
	for i in _get_enemy_amount(wave_index):
		_spawn_enemy(wave_index, _get_enemy_level(wave_index))
		
		spawn_interval.start()
		await spawn_interval.timeout
	
	spawn_interval.wait_time = interval_to_boss
	
	spawn_interval.start()
	await spawn_interval.timeout
	
	_spawn_boss(wave_index)


func _spawn_enemy(wave_index : int = 0, enemy_level : int = 1) -> void:
	var new_enemy : EnemyEntity = EnemiesFile.get(_get_random_enemy(wave_index)).instantiate() as EnemyEntity
	level_node.add_child(new_enemy)
	
	new_enemy.enemy_level = enemy_level
	new_enemy._set_level_mod()
	
	new_enemy.player_ref = level_node.player_node
	new_enemy.global_position.x = spawn_point
	new_enemy.global_position.y = -256.0
	new_enemy.enemy_defeated.connect(_reduce_from_counter)

func _spawn_boss(wave_index : int = 0) -> void:
	var new_boss : EnemyEntity = EnemiesFile.get(_get_boss(wave_index)).instantiate() as EnemyEntity
	level_node.add_child(new_boss)
	
	new_boss.player_ref = level_node.player_node
	new_boss.global_position.x = spawn_point
	new_boss.global_position.y = -256.0
	new_boss.enemy_defeated.connect(_reduce_from_counter)


func _reduce_from_counter() -> void:
	enemies_in_wave -= 1
	print("Remaining enemies : ", enemies_in_wave)
	
	if enemies_in_wave < 1:
		enemies_in_wave = 0
		
		wave_completed.emit()
		ScreenEffects._wave_complete()
		
		if ((current_wave + 1) > waves.size() - 1):
			_spawn_wave(current_wave)
		else:
			_spawn_wave(current_wave + 1)


#region Get Info Functions
func _get_time_to_start(wave_index : int = 0) -> float:
	return waves[wave_index].time_until_start

func _get_enemy_amount(wave_index : int = 0) -> int:
	return waves[wave_index].enemies_until_boss

func _get_random_enemy(wave_index : int = 0) -> String:
	randomize()
	return waves[wave_index].random_enemies_to_spawn.pick_random()

func _get_boss(wave_index : int = 0) -> String:
	return waves[wave_index].boss_to_spawn

func _get_enemy_level(wave_index : int = 0) -> int:
	return randi_range(1, waves[wave_index].enemies_max_level)
#endregion
