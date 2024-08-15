class_name UpgradeArea extends Area2D

static var has_upgrade : bool = false
@export var upgrade_hud : ResourceHud
@export var wave_system : EnemyWaveSpawner
@export var game_system : GameSystem
@export var base_generator : BaseGenerator
@onready var upgrade_particles: GPUParticles2D = $UpgradeParticles
@export var upgrade_buttons : Array[TextureButton]
@onready var upgrade_screen: CanvasLayer = $UpgradeScreen
@onready var upgrade_screen_anim: AnimationPlayer = $UpgradeScreen/Control/UpgradeScreenAnim
@onready var got_upgrade: AudioStreamPlayer = $UpgradeScreen/GotUpgrade


var has_player : bool = false
static var IsOnUpgrade : bool = false

const UPGRADES : Array[String] = [
	"TURRET DMG", "TURRET HP",
	"PLAYER DMG", "PLAYER HP", "PLAYER ATKSPD"
]

var selected_upgrades : Array[String]
var selected_values : Array[float]
var selected_costs : Array[int]

var selected_index : int

signal upgrade_selected (index : int)

func _ready() -> void:
	has_upgrade = false
	upgrade_particles.emitting = false
	upgrade_screen.hide()
	set_physics_process(false)
	
	wave_system.wave_completed.connect(_set_new_upgrade)


func _physics_process(delta: float) -> void:
	if has_player == true and has_upgrade == true:
		var interaction := Input.is_action_just_pressed(&"collect")
		
		if interaction:
			IsOnUpgrade = true
			game_system.player_node.player_hud.hide()
			upgrade_screen_anim.play(&"OpenUpgrade")
			
			get_tree().set_pause(true)
			await upgrade_selected
			
			match selected_index:
				0:
					pass
				1:
					pass
				2:
					pass
				-1:
					pass
	else:
		get_tree().set_pause(false)


func _apply_upgrade(upgrade_name : String):
	got_upgrade.play()
	game_system.player_node.player_hud.show()
	has_player = false
	has_upgrade = false
	IsOnUpgrade = false
	upgrade_hud._hide_off()
	
	for button in upgrade_buttons:
		button.release_focus()
	
	upgrade_particles.emitting = false
	set_physics_process(false)
	get_tree().set_pause(false)
	
	match upgrade_name:
		"TURRET DMG":
			for turret in base_generator.turrets:
				turret.attack_damage += turret.attack_damage * selected_values[selected_index]
		"TURRET HP":
			for turret in base_generator.turrets:
				turret.hit_points += turret.hit_points * selected_values[selected_index]
				turret.current_hit_points = turret.hit_points
				turret._was_damaged.emit()
		"PLAYER DMG":
			game_system.player_node.base_damage += game_system.player_node.base_damage * selected_values[selected_index]
		"PLAYER HP":
			game_system.player_node.max_health += game_system.player_node.max_health * selected_values[selected_index]
			game_system.player_node.current_health = game_system.player_node.max_health
			game_system.player_node.damage_taken.emit(0)
		"PLAYER ATKSPD":
			game_system.player_node.attack_cooldown -= game_system.player_node.attack_cooldown * selected_values[selected_index]


func _set_new_upgrade() -> void:
	if has_upgrade == false:
		has_upgrade = true
		upgrade_particles.emitting = true
		set_physics_process(true)
		
		_randomize_buttons()


func _on_body_entered(body: Node2D) -> void:
	if IsOnUpgrade == false:
		if body is PlayerEntity:
			has_player = true
	if has_upgrade == true:
		upgrade_hud._show_up()

func _on_body_exited(body: Node2D) -> void:
	if IsOnUpgrade == false:
		if body is PlayerEntity:
			has_player = false
	if has_upgrade == true:
		upgrade_hud._hide_off()


func _randomize_buttons() -> void:
	selected_upgrades.clear()
	selected_values.clear()
	selected_costs.clear()
	
	for i in 3:
		randomize()
		var upgrade : String = UPGRADES.pick_random() as String
		var value : float = randf_range(0.1, 0.5)
		var cost : int = roundi(lerpf(1.0, 5.0, value * 2.0))
		
		selected_upgrades.append(upgrade)
		selected_values.append(value)
		selected_costs.append(cost)
		
		(upgrade_buttons[i].get_child(0) as Label).text = str("+",round(value * 100.0),"%\n",upgrade)
		(upgrade_buttons[i].get_child(1).get_child(1) as Label).text = str("x ", cost," ")


func _on_upgrade_button_1_pressed() -> void:
	if PlayerEntity.ComponentAmount >= selected_costs[0]:
		PlayerEntity.ComponentAmount -= selected_costs[0]
		selected_index = 0
		_apply_upgrade(selected_upgrades[0])
		upgrade_selected.emit(0)
		upgrade_screen.hide()


func _on_upgrade_button_2_pressed() -> void:
	if PlayerEntity.ComponentAmount >= selected_costs[1]:
		PlayerEntity.ComponentAmount -= selected_costs[2]
		selected_index = 1
		_apply_upgrade(selected_upgrades[1])
		upgrade_selected.emit(1)
		upgrade_screen.hide()


func _on_upgrade_button_3_pressed() -> void:
	if PlayerEntity.ComponentAmount >= selected_costs[2]:
		PlayerEntity.ComponentAmount -= selected_costs[2]
		selected_index = 2
		_apply_upgrade(selected_upgrades[2])
		upgrade_selected.emit(2)
		upgrade_screen.hide()


func _on_return_button_pressed() -> void:
	has_player = false
	get_tree().set_pause(false)
	upgrade_screen.hide()
