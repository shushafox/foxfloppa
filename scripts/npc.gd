extends ActorBase

@onready var PeaceCollider = $Peace/DetectionArea
@onready var CombatCollider = $Combat/DetectionArea

@onready var Player = get_parent().get_parent().get_node("Player")

var animUp = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_sprite()
	
	Player.NpcInterract.connect(_on_npc_interract)
	
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

func GetCurrentCollider() -> Area2D:
	if $Combat.process_mode == Node.ProcessMode.PROCESS_MODE_DISABLED:
		return PeaceCollider
	else:
		return CombatCollider

func _on_npc_interract() -> void:
	var bodies:Array[Node2D] = GetCurrentCollider().get_overlapping_bodies()
	var isPlayer = false
	
	for body in bodies:
		if body.name == "Player":
			isPlayer = true
	
	if isPlayer:
		Dialogic.start(Autoload.NpcTimeLineResolver(DisplayName))

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		animUp = 0
		var tween = get_tree().create_tween()
		tween.tween_property(Sprite,"skew", 0, 1)
		Sprite.scale += Vector2(0.5, 0.5)

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		Sprite.scale -= Vector2(0.5, 0.5)
		ResetAnim()
