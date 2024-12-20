extends StaticBody2D

@export var sprite: String
@export var timeline: String

@onready var Sprite = $Sprite2D
@onready var Collider = $Area2D
@onready var Player = $"../Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Player.onNpcInterract.connect(_onNpcInterract)
	
	var image = load(sprite)
	Sprite.texture = image

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _onNpcInterract() -> void:
	var bodies:Array[Node2D] = Collider.get_overlapping_bodies()
	var isPlayer = false
	
	for body in bodies:
		if body.name == "Player":
			isPlayer = true
	
	if isPlayer:	
		Dialogic.start(timeline)
