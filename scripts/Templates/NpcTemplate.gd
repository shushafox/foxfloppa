extends ActorBase

@onready var PeaceCollider = $Peace/DetectionArea
@onready var CombatCollider = $Combat/DetectionArea
@onready var Level: LevelBase = get_parent().get_parent()
@onready var NavAgent: NavigationAgent2D = $Combat/NavigationAgent
@onready var Player: ActorBase = get_parent().get_parent().get_node("Player")

var CurrentTurn: bool = false

var animUp = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_sprite()
	
	Player.NpcInterract.connect(_on_npc_interract)
	
	Animate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if CurrentTurn:
		if NavAgent.is_navigation_finished():
			return
		
		var direction = to_local(NavAgent.get_next_path_position()).clamp(-Vector2.ONE,Vector2.ONE).round()
		
		if RemainingSpeed > 0:
			move(direction)
		else:
			CurrentTurn = false
			EndTurn.emit()

func Animate():
	if(animUp == 1):
		animUp = 2
		var tween = get_tree().create_tween()
		tween.tween_property(AnimatedSprite,"skew", 0.5, 1)
		tween.finished.connect(Animate)
	elif(animUp == 2):
		animUp = 1
		var tween = get_tree().create_tween()
		tween.tween_property(AnimatedSprite,"skew", -0.5, 1)
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

func _on_turn_start(node: ActorBase) -> void:
	if node != self:
		return
	
	NavAgent.target_position = Player.global_position
	
	CurrentTurn = true
	RemainingSpeed = Speed

func move(direction: Vector2i) -> void:
	var currentTile: Vector2i = Level.Tiles.local_to_map(self.global_position)
	var targetTile: Vector2i = Vector2(
		currentTile.x + direction.x,
		currentTile.y + direction.y
	)
	var tileData: TileData = Level.Tiles.get_cell_tile_data(targetTile)
	var tween = create_tween()
	tween.tween_property(AnimatedSprite, "global_position", Level.Tiles.map_to_local(targetTile), 0.5)
	await get_tree().create_timer(1).timeout
	#self.global_position = Level.Tiles.map_to_local(targetTile)
	
	RemainingSpeed -= 1

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
		tween.tween_property(AnimatedSprite,"skew", 0, 1)
		#AnimatedSprite.scale += Vector2(0.5, 0.5)

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		#AnimatedSprite.scale -= Vector2(0.5, 0.5)
		ResetAnim()
