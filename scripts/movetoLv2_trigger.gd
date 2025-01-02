extends Area2D

@onready var Level: LevelBase = get_parent().get_parent()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		_movetolevel2()

func _movetolevel2() -> void:
	if get_tree().get_current_scene().get_name() == "Level1":
		get_tree().change_scene_to_file("res://scenes/Level2.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/Level1.tscn")
