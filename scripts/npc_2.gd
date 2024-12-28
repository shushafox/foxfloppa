extends StaticBody2D

@export var ESprite: String
@export var EName: String

@onready var Sprite = $Sprite2D
@onready var Collider = $Area2D
@onready var Player = $"../Player"

var animUp = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Player.onNpcInterract.connect(_onNpcInterract)
	
	var image = load(ESprite)
	Sprite.texture = image
	
	Animate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func Animate():
	if(animUp == 1):
		animUp = 2
		var tween = get_tree().create_tween()
		tween.tween_property(Sprite,"skew", 0.5, 1)
		tween.finished.connect(Animate)
	elif(animUp == 2):
		animUp = 1
		var tween = get_tree().create_tween()
		tween.tween_property(Sprite,"skew", -0.5, 1)
		tween.finished.connect(Animate)

func ResetAnim():
	if animUp == 1:
		animUp = 2
	if animUp == 2:
		animUp = 1
	if animUp == 0:
		animUp = 1
	
	Animate()

func _onNpcInterract() -> void:
	var bodies:Array[Node2D] = Collider.get_overlapping_bodies()
	var isPlayer = false
	
	for body in bodies:
		if body.name == "Player":
			isPlayer = true
	
	if isPlayer:	
		Dialogic.start(Autoload.NpcTimeLineResolver(EName))

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		animUp = 0
		
		var tween = get_tree().create_tween()
		tween.tween_property(Sprite,"skew", 0, 1)
			
		scale += Vector2(1,1)
		print("actionable")
		print("Counter ", Dialogic.VAR.Counter)
		print("GlobalCounter ", Autoload.GlobalCounter)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		scale -= Vector2(1,1)
		
		ResetAnim()
		
		print("actionable no more")
		print("Counter ", Dialogic.VAR.Counter)
		print("GlobalCounter ", Autoload.GlobalCounter)
