extends TextureProgressBar

@export var entity : EnemyEntity
@export var structure : GameStructure


func _ready() -> void:
	hide()
	
	if entity:
		entity.damage_taken.connect(_update_entity_health)
	elif structure:
		structure._was_damaged.connect(_update_structure_health)
		structure._was_ruined.connect(_hide_structure_health)
	else:
		queue_free()


func _update_entity_health() -> void:
	show()
	var ratio : float = inverse_lerp(0, entity.max_health, entity.current_health)
	
	value = ratio

func _update_structure_health() -> void:
	show()
	var ratio : float = inverse_lerp(0, structure.hit_points, structure.current_hit_points)
	
	value = ratio

func _hide_structure_health() -> void:
	hide()
