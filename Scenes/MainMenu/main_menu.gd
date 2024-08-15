extends CanvasLayer

@onready var menu_anim: AnimationPlayer = $MenuAnim

func _on_play_game_pressed() -> void:
	if not menu_anim.is_playing():
		menu_anim.play(&"ToGame")
		await menu_anim.animation_finished
		
		get_tree().change_scene_to_file("res://Scenes/MainGameScene/main_game_scene.tscn")
