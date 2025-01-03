extends Area2D

@onready var Level: LevelBase = get_parent().get_parent()

@export var Destination: String

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		_change_level()

func _change_level() -> void:
	get_tree().change_scene_to_file(Destination)
