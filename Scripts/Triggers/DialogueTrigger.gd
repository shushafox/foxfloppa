extends Area2D

@export var Timeline: String
@export var Triggered: bool
@export var Repeatable: bool

func _ready() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and !Triggered or Repeatable:
		Dialogic.start(Timeline)
		Triggered = true
