extends ActorBase

@onready var PeaceCollider = $Peace/DetectionArea
@onready var CombatCollider = $Combat/DetectionArea
@onready var NavAgent: NavigationAgent2D = $Combat/NavigationAgent
@onready var Player: ActorBase = get_parent().get_parent().get_node("Player")

var animUp = 1

func _ready() -> void:
	_set_sprite()
	_set_targeting_area()
	
	Level = get_parent().get_parent()
	Player.Interract.connect(_on_npc_interract)
	
	Animate()

func _process(_delta: float) -> void:
	if IsCurrentTurn && !IsActing && !IsMoving:
		_calculate_turn_abilities()
		
		if CanMove:
			if NavAgent.is_navigation_finished():
				CanMove = false
			if RemainingSpeed > 0:
				var direction = to_local(NavAgent.get_next_path_position()).normalized().round()
				move(direction)
		else:
			IsCurrentTurn = false
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

func get_collider() -> Area2D:
	if Combat.process_mode == Node.ProcessMode.PROCESS_MODE_DISABLED:
		return PeaceCollider
	else:
		return CombatCollider

func move(direction: Vector2i) -> void:
	if (direction.x != 0 && direction.y != 0):
		var vertical = Vector2(direction.x, 0)
		
		Raycast.target_position = direction * 48
		Raycast.force_raycast_update()
		
		if !Raycast.is_colliding():
			direction = vertical
		else:
			direction = Vector2(0, direction.y)
	
	var currentTile: Vector2i = Level.Tiles.local_to_map(self.global_position)
	var targetTile: Vector2i = Vector2(
		currentTile.x + direction.x,
		currentTile.y + direction.y
	)
	var tileData: TileData = Level.Tiles.get_cell_tile_data(targetTile)
	
	Raycast.target_position = direction * 48
	Raycast.force_raycast_update()
	
	if Raycast.is_colliding():
		CanMove = false
		RemainingSpeed = 0
		return
	if (tileData.get_custom_data("Walkable") == false):
		CanMove = false
		RemainingSpeed = 0
		return
	
	IsMoving = true
	
	var tween = create_tween()
	tween.tween_property(self, "position", Level.Tiles.map_to_local(targetTile), 0.5)
	tween.finished.connect(func(): IsMoving = false)
	
	RemainingSpeed -= 1

func _on_turn_start(node: ActorBase) -> void:
	if node != self:
		return
	
	var target = _get_target()
	if target == null:
		target = Player
	
	NavAgent.target_position = target.global_position
	
	IsCurrentTurn = true
	RemainingSpeed = Speed

func _on_npc_interract() -> void:
	var bodies:Array[Node2D] = get_collider().get_overlapping_bodies()
	
	for body in bodies:
		if body.name == "Player":
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
