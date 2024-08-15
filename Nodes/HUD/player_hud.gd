class_name PlayerHud extends CanvasLayer

@export var player_node : PlayerEntity
@export_group("Internal Hud Nodes")
@export_subgroup("Life Bar")
@export var life_bar : TextureProgressBar
@export var life_num : Label
@export_subgroup("Ammo Bar")
@export var ammo_bar : TextureProgressBar
@export var reload_bar : TextureProgressBar
@export var ammo_num : Label
@export_subgroup("Wave Attack Info")
@export var skip_timer_button : Button
@export var wave_timer : Label
@export var attack_info_panel : PanelContainer
@export_subgroup("Resource Counting")
@export var wood_count : Label
@export var metal_count : Label
@export var component_count : Label

const INV_COLOR : Color = Color(1.0, 0.0, 0.0, 0.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_wood()
	_update_metal()
	_update_component()
	
	player_node.damage_taken.connect(_update_life_bar)
	
	player_node.got_wood.connect(_update_wood)
	player_node.got_metal.connect(_update_metal)
	player_node.got_component.connect(_update_component)


func _process(delta: float) -> void:
	if player_node.enemy_wave_spawner.wave_timer.is_stopped():
		if attack_info_panel.modulate.a > 0.0:
			attack_info_panel.modulate.a -= delta
		
	else:
		if attack_info_panel.modulate.a < 1.0:
			attack_info_panel.modulate.a += delta
		
		wave_timer.text = str(snappedf(player_node.enemy_wave_spawner.wave_timer.time_left, 1.0), ". s\n to next attack")


func _update_life_bar(last_dmg : int = 0) -> void:
	var ratio : float = inverse_lerp(0, player_node.max_health, player_node.current_health)
	
	life_num.text = str(player_node.current_health,"/",player_node.max_health)
	
	life_bar.tint_over = Color.WHITE
	var color_tween : Tween = create_tween().set_parallel(true)
	color_tween.stop()
	color_tween.tween_property(life_bar, "tint_over", INV_COLOR, player_node.inv_time)
	color_tween.tween_property(life_bar, "value", ratio, player_node.inv_time)
	color_tween.play()

func _update_ammo_bar() -> void:
	pass


#region Update Resource Counter
func _update_wood() -> void:
	wood_count.text = str(player_node.WoodAmount)

func _update_metal() -> void:
	metal_count.text = str(player_node.MetalAmount)

func _update_component() -> void:
	component_count.text = str(player_node.ComponentAmount)
#endregion


func _on_skip_timer_pressed() -> void:
	player_node.enemy_wave_spawner._skip_await_timer()
	skip_timer_button.release_focus()
