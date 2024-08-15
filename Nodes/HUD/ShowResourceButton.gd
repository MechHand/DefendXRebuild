extends Button

@export var resource_panel : PanelContainer

const RESOURCE_BUTTON_1 = preload("res://Nodes/HUD/InGameHud/ResourceArea/ResourceButton1.png")
const RESOURCE_BUTTON_2 = preload("res://Nodes/HUD/InGameHud/ResourceArea/ResourceButton2.png")

var is_pressed : bool = false

const SHOWING_POS : Vector2 = Vector2(0.0, 97.0)
const HIDING_POS : Vector2 = Vector2(0.0, 144.0)

func _ready() -> void:
	icon = RESOURCE_BUTTON_1
	resource_panel.position = HIDING_POS
	release_focus()

func _pressed() -> void:
	if is_pressed == true:
		is_pressed = false
		icon = RESOURCE_BUTTON_1
		_move_to_down()
		release_focus()
	else:
		is_pressed = true
		icon = RESOURCE_BUTTON_2
		_move_to_up()
		release_focus()

func _move_to_up() -> void:
	var move_tween : Tween = create_tween().set_parallel(true)
	
	move_tween.stop()
	move_tween.tween_property(resource_panel, "position", SHOWING_POS, 0.5)
	move_tween.play()
	
	await move_tween.finished
	move_tween.kill()

func _move_to_down() -> void:
	var move_tween : Tween = create_tween().set_parallel(true)
	
	move_tween.stop()
	move_tween.tween_property(resource_panel, "position", HIDING_POS, 0.5)
	move_tween.play()
	
	await move_tween.finished
	move_tween.kill()
