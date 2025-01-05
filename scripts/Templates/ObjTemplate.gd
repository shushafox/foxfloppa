extends ObjectBase

@onready var Collider = $DetectionArea
@onready var Player = get_parent().get_parent().get_node("Player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Player.ObjInterract.connect(_on_obj_interract)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func GetCurrentCollider() -> Area2D:
	return Collider
	
func _on_obj_interract() -> void:
	var bodies:Array[Node2D] = GetCurrentCollider().get_overlapping_bodies()
	var isPlayer = false
	
	for body in bodies:
		if body.name == "Player":
			isPlayer = true
	
	if isPlayer:
		Dialogic.start(Autoload.NpcTimeLineResolver(DisplayName))
