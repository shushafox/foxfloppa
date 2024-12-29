extends Camera2D

@onready var Level: Node2D = get_parent().get_parent()
@onready var Player: CharacterBody2D = Level.get_node("Player")
@onready var Target: Node2D = Player

var IsFocused: bool = true

func _process(delta: float) -> void:
	if (IsFocused):
		self.position = lerp(self.position, Target.position, 1)
	else:
		pass
