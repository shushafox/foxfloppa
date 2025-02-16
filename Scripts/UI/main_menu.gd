extends Control

func _ready() -> void:
	$Background.play("gif")

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level1.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
