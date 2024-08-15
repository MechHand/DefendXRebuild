class_name GameSystem extends Node2D

@export var player_node : PlayerEntity

signal _start_game
var game_started : bool = false

@onready var normal_ost: AudioStreamPlayer = $NormalOST
@onready var battle_ost: AudioStreamPlayer = $BattleOST

func _ready() -> void:
	VfxSpawner.level_node = self


func _on_time_to_start_game_timeout() -> void:
	_start_game.emit()
	game_started = true
	
	normal_ost.play()
	battle_ost.stop()


func _on_enemy_wave_spawner_wave_started() -> void:
	normal_ost.stop()
	battle_ost.play()

func _on_enemy_wave_spawner_wave_completed() -> void:
	normal_ost.play()
	battle_ost.stop()
