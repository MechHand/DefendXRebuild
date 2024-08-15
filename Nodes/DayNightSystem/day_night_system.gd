class_name DayLightSystem extends Node2D

@export_group("DayNight Parameters")
@export_range(0.0, 1.0, 0.01) var time_ratio : float = 0.0
@export_group("Visual Parameters")
@export var day_night_colors : GradientTexture1D
@export var sun_intensity : Curve
@export var max_sun_energy : float = 0.5
@export var min_sun_energy : float = 0.025

@onready var ambient_color: CanvasModulate = $AmbientColor as CanvasModulate
@onready var sun_node: DirectionalLight2D = $SunNode as DirectionalLight2D
@onready var time_tick: Timer = $TimeTick as Timer

const TIMETICK_ADD : float = 0.001
const SUN_INITIAL_ANGLE : float = -90
const SUN_FINAL_ANGLE : float = 90

signal _sky_ambient_updated

static var world_time : float = 0.0

func _ready() -> void:
	_update_sky_color()


func _update_sky_color() -> void:
	time_ratio += TIMETICK_ADD
	
	if time_ratio > 1.0:
		time_ratio = 0.0
	
	ambient_color.color = day_night_colors.gradient.sample(time_ratio)
	
	if time_ratio < 0.5:
		sun_node.energy = lerpf(min_sun_energy, max_sun_energy, sun_intensity.sample(time_ratio * 2.0))
		sun_node.rotation_degrees = lerpf(SUN_INITIAL_ANGLE, SUN_FINAL_ANGLE, time_ratio * 2.0)
	else:
		sun_node.energy = min_sun_energy
		sun_node.rotation_degrees = lerpf(SUN_FINAL_ANGLE - 90, SUN_FINAL_ANGLE + 180, time_ratio)
	
	world_time = time_ratio
	_sky_ambient_updated.emit()


func _on_time_tick_timeout() -> void:
	_update_sky_color()
	time_tick.start()
