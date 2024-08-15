class_name WaveInfo extends Resource

@export_range(5.0, 240.0, 5.0, "or_greater", "suffix:seconds") var time_until_start : float = 60.0
@export var enemies_until_boss : int = 5
@export var enemies_max_level : int = 1
@export var random_enemies_to_spawn : Array[String]
@export var boss_to_spawn : String
 
