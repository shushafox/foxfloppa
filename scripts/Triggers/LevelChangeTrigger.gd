extends Area2D

signal ChangeScene(path: String)

@onready var Level: LevelBase = get_parent().get_parent()

@export var Destination: String

func _ready() -> void:
	ChangeScene.connect(LevelManager.change_scene)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		ChangeScene.emit(Destination)
