extends Node2D

@onready var Grass = $Grass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Autoload.IsDay):
		Grass.modulate = Color.WHITE
	else: 
		Grass.modulate = Color.DARK_BLUE
