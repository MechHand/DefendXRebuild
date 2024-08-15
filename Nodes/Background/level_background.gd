class_name LevelBackground extends ParallaxBackground

@export var daylight_system : DayLightSystem
@onready var ambient_color: CanvasModulate = $AmbientColor
@onready var space_sun: DirectionalLight2D = %SpaceSun

func _ready() -> void:
	if daylight_system:
		daylight_system._sky_ambient_updated.connect(_sync_sky_ambient)

func _sync_sky_ambient() -> void:
	ambient_color.color = daylight_system.ambient_color.color
	space_sun.rotation_degrees = daylight_system.sun_node.rotation_degrees
