class_name GameStructure extends Node2D

enum State { ## Os possíveis estados da estrutura.
	Ruined, ## Estrutura destruída, não funciona
	Working, ## Estrutura funcionando corretametne.
} 
enum Materials { ## Materiais usados para construção e reparação
	Wood, ## Material simples, coletado de arvores.
	Metal, ## Material médio, coletado de minérios expostos.
	Component, ## Material avançado, coletado de partes robóticas.
}

@export_group("Structure Stats")
@export var current_state : State = State.Ruined ## O estado inicial da estrutura.
@export var points_to_repair : int = 8 ## Quantidade de materiais necessários para a reparação.
@export var material_to_repair : Materials = Materials.Wood ## Tipo de material necessário para a reparação.
@export var structure_hurtbox : Area2D ## Colisão usada para receber dano.
@export_group("Structure Parameters")
@export var hit_points : int = 15 ## Pontos de saúde.
@onready var current_hit_points : int = hit_points
@export var attack_damage : int = 2 ## Dano por ataque.
@export var attack_cooldown : float = 1.25 ## Intervalo entre ataques.

const INV_TIME : float = 0.5
var can_take_damage : bool = true

signal _was_repaired (structure : GameStructure) ## Emitido quando a estrutura é restaurada.
signal _was_ruined () ## Emitido quando a estrutura é destruida.

signal _was_damaged ## Emitido quando a estrutura recebe dano.


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


## Verifica se é possível ser reparado, se sim, muda o estado para Working e tem sua vida restaurada.
func _try_repair(material_amount : int) -> void:
	if current_state == State.Ruined:
		if material_amount >= points_to_repair:
			current_hit_points = hit_points
			current_state = State.Working
			_was_repaired.emit(self)


## Recebe dano, caso a vida chege a menos de zero, a estrturua entra no estado Ruined.
func _take_damage(amount : int) -> void:
	if can_take_damage == true and current_state == State.Working:
		can_take_damage = false
		current_hit_points -= amount
		_was_damaged.emit()
		
		if current_hit_points <= 0:
			current_hit_points = 0
			current_state = State.Ruined
			VfxSpawner._spawn_explosion(global_position - Vector2(0.0, 8.0))
			_was_ruined.emit()
		
		_inv_timer()


## Corotina - Cria um timer e espera ele terminar, após terminar, é possível tomar dano novamente.
func _inv_timer() -> void:
	await get_tree().create_timer(INV_TIME).timeout
	can_take_damage = true
