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

func _input(_event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && IsAiming:
		var pos = Tiles.map_to_local(Tiles.local_to_map(get_local_mouse_position()))
		TempAbility.use_on_target(pos)
		
		AbilityRange.queue_free()
		TempAbility = null
		IsAiming = false
