extends Node2D

@onready var sparkles_pivot: Node2D = $SparklesPivot as Node2D


func _ready() -> void:
	randomize()
	sparkles_pivot.rotation_degrees = randf_range(-360, 360)
	for child in sparkles_pivot.get_children():
		if child is Node2D:
			randomize()
			child.scale.x = randf_range(0.75, 1.25)
