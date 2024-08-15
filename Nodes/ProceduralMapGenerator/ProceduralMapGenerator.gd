@tool
class_name ProceduralMapGenerator extends Node

@export_group("Procedural Values")
@export var seed : int = 0
@export var procedural_curve : Curve ## Curva utilizada para gerar o terreno, cada ponto é uma altura no relevo.
@export_range(64, 256, 8) var map_size : int = 64 ## O tamanho do mapa em quantidade de tiles. (64 tiles equivalem a 512 pixels)
@export_range(0.05, 1.0, 0.05) var min_heigth : float = 0.5 ## Altura minima do relevo.
@export_range(0.05, 1.0, 0.05) var max_heigth : float = 0.8 ## Altura máxima do relevo.

const MIN_WORLD_HEIGTH : int = 0 ## Altura mínima para os tiles serem posicionados.
const MAX_WORLD_HEIGTH : int = 64 ## Altura máxima para os tiles serem posicionados.

static var MapCameraLimitsTopLeft : Vector2
static var MapCameraLimitsBottonRight : Vector2
static var GlobalSeed : int

@onready var base_terrain_tilemap: TileMap = $BaseTerrainTilemap as TileMap ## O tilemap usado para gerar o nível
@onready var left_collision: CollisionShape2D = $WorldBarrier/LeftCollision
@onready var right_collision: CollisionShape2D = $WorldBarrier/RightCollision

const SOURCE_ID : int = 0

signal _map_generated

const ALIEN_TREE_RESOURCE = preload("res://Nodes/Terrain/WorldResources/AlienTree/AlienTree_Resource.tscn")
const METAL_PIECES_RESOURCE = preload("res://Nodes/Terrain/WorldResources/MetalPieces/MetalPieces_Resource.tscn")

const MIN_TREE_AMOUNT_IN_WOODS : int = 1
const MAX_TREE_AMOUNT_IN_WOODS : int = 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	seed = randi_range(-256, 256)
	
	_reset_curve()
	_randomize_curve()
	
	_generate_level()
	
	_set_world_boundaries()


## Gera o nível procedural
func _generate_level() -> void:
	base_terrain_tilemap.clear()
	
	var cells : Array[Vector2i]
	
	for x in map_size:
		# Deduz o tamanho do mapa para pegar pontos de altura na curva procedural.
		var map_pos : float = inverse_lerp(0.0, float(map_size), float(x))
		var height_value : float = procedural_curve.sample(map_pos)
		
		var calculated_heigth : int = lerp(MIN_WORLD_HEIGTH, MAX_WORLD_HEIGTH, height_value)
		
		for y in MAX_WORLD_HEIGTH:
			if y < calculated_heigth:
				if x == 0:
					cells.append(Vector2i(-1, -y))
					cells.append(Vector2i(x, -y))
				elif x == map_size - 1:
					cells.append(Vector2i(x + 1, -y))
					cells.append(Vector2i(x, -y))
				else:
					cells.append(Vector2i(x, -y))
		
		cells.append(Vector2i(x, 1))
	
	# Posiciona os tiles.
	base_terrain_tilemap.set_cells_terrain_connect(0, cells, 0, 0)
	
	# Atualiza os limites que a camera poderia ficar
	MapCameraLimitsTopLeft = Vector2(0.0, base_terrain_tilemap.global_position.y - (MAX_WORLD_HEIGTH * 8))
	MapCameraLimitsBottonRight = Vector2(map_size * 8, base_terrain_tilemap.global_position.y)
	
	# Atualiza a seed global.
	GlobalSeed = seed
	
	# Gera os detalhes do terreno
	_generate_resources(3, 3)
	
	_map_generated.emit()

## Coloca as colisões nos limites do mapa.
func _set_world_boundaries() -> void:
	left_collision.global_position = Vector2(0, 144)
	right_collision.global_position = Vector2(map_size * 8, 144)

## Modifica todos os pontos da curva procedural para afetar o relevo.
func _randomize_curve() -> void:
	for point in procedural_curve.point_count:
		seed((seed + 1) * point)
		
		procedural_curve.set_point_value(point, randf_range(min_heigth, max_heigth))

## Reseta a curva procedural.
func _reset_curve() -> void:
	for point in procedural_curve.point_count:
		procedural_curve.set_point_value(point, 1.0)


func _generate_resources(forest_amount : int, mines_amount : int) -> void:
	for i in forest_amount:
		var tree_to_generate : int = round(lerp(MAX_TREE_AMOUNT_IN_WOODS, MIN_TREE_AMOUNT_IN_WOODS, inverse_lerp(0, forest_amount, i)))
		
		var sample_pos : float = procedural_curve.get_point_position(procedural_curve.get_point_count() - (i * 2) - 1).x
		var woods_position : float = lerpf(0.0, float(map_size) * 8.0, sample_pos) - 64.0
		
		var last_tree_spawned_interval : float = 0
		
		for j in tree_to_generate:
			var new_tree : WorldResource = ALIEN_TREE_RESOURCE.instantiate() as WorldResource
			add_child(new_tree)
			
			seed(GlobalSeed + (j * (i + 1)))
			var interval : float = (j * randi_range(0, 16))
			var x_pos : float = woods_position + interval + last_tree_spawned_interval
			
			last_tree_spawned_interval += interval + 24
			
			new_tree.global_position = Vector2(x_pos, -256.0)
	
	for i in mines_amount:
		var sample_pos : float = procedural_curve.get_point_position(procedural_curve.get_point_count() - (i * 2) - 1).x
		var metal_position : float = lerpf(0.0, float(map_size) * 8.0, sample_pos) - 128.0
		
		var new_metal : WorldResource = METAL_PIECES_RESOURCE.instantiate() as WorldResource
		add_child(new_metal)
			
		seed(GlobalSeed + (i + 1))
		var interval : float = randi_range(-16, 16)
		var x_pos : float = metal_position + interval
			
		new_metal.global_position = Vector2(x_pos, -256.0)

