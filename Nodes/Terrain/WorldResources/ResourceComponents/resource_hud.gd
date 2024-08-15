class_name ResourceHud extends Control

@export var animation_player: AnimationPlayer
@export var collect_progress: TextureProgressBar


func _update_progress(new_value : float) -> void:
	if collect_progress:
		collect_progress.value = new_value


func _show_up() -> void:
	_update_progress(0.0)
	if animation_player:
		animation_player.play(&"ShowUp")

func _hide_off() -> void:
	if animation_player:
		animation_player.play(&"HideOff")
