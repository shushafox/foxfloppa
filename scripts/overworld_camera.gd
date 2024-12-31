extends Camera2D

@onready var Level: Node2D = get_parent().get_parent()

@export var Target: Node2D

var IsFocused: bool = true

func _ready() -> void:
	if !Target:
		Target =  get_parent().get_parent().get_node("Player")

func _process(delta: float) -> void:
	if (IsFocused):
		self.position = lerp(self.position, Target.position, 1)
	else:
		pass
