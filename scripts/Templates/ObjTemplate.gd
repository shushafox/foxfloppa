extends ObjectBase

func _ready() -> void:
	Player.Interract.connect(_on_obj_interract)

func _on_obj_interract() -> void:
	var bodies:Array[Node2D] = get_collider().get_overlapping_bodies()
	
	for body in bodies:
		if body.name == "Player":
			Dialogic.start(Autoload.NpcTimeLineResolver(DisplayName))
