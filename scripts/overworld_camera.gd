extends Camera2D

@onready var Level: Node2D = get_parent().get_parent()

@export var Target: Node2D

var IsFocused: bool = true

func _ready() -> void:
	if !Target:
		Target =  get_parent().get_parent().get_node("Player")

func focus(target: Node2D) -> void:
	IsFocused = true
	Target = target

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Home") && !IsFocused:
		self.position = self.position.move_toward(Level.Player.position, 1)

func _process(_delta: float) -> void:
	if (IsFocused):
		self.position = lerp(self.position, Target.position, 1)
	else:
		pass
