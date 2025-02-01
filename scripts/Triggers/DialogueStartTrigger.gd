extends Area2D

@export var Timeline: String
@export var Triggered: bool


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and !Triggered:
		Triggered = !Triggered
		Dialogic.start_timeline(Timeline)
