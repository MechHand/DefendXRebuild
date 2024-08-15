class_name ResourceNeeded extends Control

@onready var resource_icon: Sprite2D = $ResourceIcon as Sprite2D
@onready var resource_amount: Label = $ResourceAmount as Label

const WOOD_OFFSET : int = 2
const METAL_OFFSET : int = 0
const COMPONENT_OFFSET : int = -2

func _update_info(amount : int, type : GameStructure.Materials) -> void:
	resource_amount.text = str(amount)
	
	match type:
		GameStructure.Materials.Wood:
			resource_icon.frame = 0
			resource_icon.offset.y = WOOD_OFFSET
		GameStructure.Materials.Metal:
			resource_icon.frame = 1
			resource_icon.offset.y = METAL_OFFSET
		GameStructure.Materials.Component:
			resource_icon.frame = 2
			resource_icon.offset.y = COMPONENT_OFFSET

func _update_allowed(allowed : bool) -> void:
	if allowed == true:
		resource_amount.modulate = Color.GREEN
	else:
		resource_amount.modulate = Color.RED
