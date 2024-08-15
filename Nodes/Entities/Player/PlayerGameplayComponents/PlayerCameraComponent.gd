class_name PlayerCameraComponent extends Camera2D

@export var procedural_map : ProceduralMapGenerator

var is_shaking : bool = false

var original_offset : Vector2

func _ready() -> void:
	if procedural_map:
		procedural_map._map_generated.connect(_update_limits)
	
	await get_tree().create_timer(0.1).timeout
	_update_limits()
	original_offset = offset


func _update_limits() -> void:
	limit_top = ProceduralMapGenerator.MapCameraLimitsTopLeft.y
	limit_left = ProceduralMapGenerator.MapCameraLimitsTopLeft.x
	
	limit_bottom = ProceduralMapGenerator.MapCameraLimitsBottonRight.y
	limit_right = ProceduralMapGenerator.MapCameraLimitsBottonRight.x


func _camera_shake(shakes : int = 4, intensity : int = 3) -> void:
	if is_shaking == false:
		is_shaking = true
		
		while (shakes > 0):
			randomize()
			
			var random_offset : Vector2 = Vector2(
				randi_range(-intensity, intensity),
				randi_range(-intensity, intensity))
			
			offset = original_offset + random_offset
			
			await get_tree().create_timer(0.05, true, false, true).timeout
			shakes -= 1
		
		offset = original_offset
		
		is_shaking = false
