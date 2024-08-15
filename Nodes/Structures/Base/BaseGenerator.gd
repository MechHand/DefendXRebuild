class_name BaseGenerator extends Node

@export var player_base : GameStructure

static var Turrets : Dictionary = {
	"Zarog85" : preload("res://Nodes/Structures/Turrets/Turret_ZaROG85/za_rog_85_turret.tscn"),
	"Vertx11" : preload("res://Nodes/Structures/Turrets/Turret_Vertx11/vertx11_turret.tscn")
}

static var TurretNames : Array[String] = ["Zarog85","Vertx11"]

var turrets : Array[GameStructure]

@export var turrets_to_generate : int = 5
@export var distance_between_structures : int = 48


func _generate_base() -> void:
	for i in turrets_to_generate:
		randomize()
		var new_turret : GameStructure
		
		if i == 0:
			new_turret = Turrets.get("Zarog85").instantiate() as GameStructure 
		else:
			new_turret = Turrets.get(TurretNames.pick_random()).instantiate() as GameStructure 
		
		add_child(new_turret)
		turrets.append(new_turret)
		
		var x_pos : float = player_base.global_position.x + (distance_between_structures * (i + 1))
		
		new_turret.global_position = Vector2(x_pos, -256.0)
