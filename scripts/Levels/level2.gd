extends LevelBase

func _ready() -> void:
	bind_signals()
	#LevelManager.obj_interaction_resolver("L2Box1")
	#Dialogic.start("wake_up")


func _process(_delta: float) -> void:
	if(Autoload.IsDay):
		Tiles.modulate = Color.WHITE
	else:
		Tiles.modulate = Color.BLUE
