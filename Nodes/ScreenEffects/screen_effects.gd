extends CanvasLayer

@onready var gameover_anim: AnimationPlayer = $GameOverScreen/GameoverAnim
@onready var wave_complete_anim: AnimationPlayer = $WaveComplete/WaveCompleteAnim

@onready var game_over_screen: Control = $GameOverScreen

func _play_game_over() -> void:
	var time_tween : Tween = create_tween().set_parallel(true)
	
	Engine.time_scale = 0.01
	time_tween.stop()
	time_tween.tween_property(Engine, "time_scale", 1.0, 0.5)
	time_tween.play()
	
	await time_tween.finished
	time_tween.kill()
	
	gameover_anim.play(&"GameOver")

func _wave_complete() -> void:
	wave_complete_anim.play(&"WaveComplete")


func _on_return_to_menu_button_pressed() -> void:
	game_over_screen.hide()
	
	get_tree().change_scene_to_file("res://Scenes/MainMenu/main_menu.tscn")
	
