extends LevelBase

func _ready() -> void:
	bind_signals()

func _process(_delta: float) -> void:	
	if(Autoload.IsDay):
		Tiles.modulate = Color.WHITE
	else:
		Tiles.modulate = Color.BLUE
