extends LevelBase

func _ready() -> void:
	Dialogic.Styles.change_style("New_File")
	bind_signals()

func _process(_delta: float) -> void:	
	if Autoload.IsDay:
		Tiles.modulate = Color.WHITE
	else:
		Tiles.modulate = Color.BLUE
	
	if IsAiming:
		aim()
