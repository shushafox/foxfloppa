extends Area2D

@onready var Level: LevelBase = get_parent().get_parent()
@export var Triggered: bool

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" && !Level.IsCombat && !Triggered:
		Level.IsCombat = true
		Level.start_combat()
		Triggered = true
