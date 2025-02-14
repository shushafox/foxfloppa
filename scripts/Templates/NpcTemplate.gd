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
	if !IsCurrentTurn || IsActing || IsMoving:
		return
	
	if IsAutoamted:
		_calculate_turn_abilities()
		
		if CanMove:
			if NavAgent.is_navigation_finished():
				CanMove = false
			if RemainingSpeed > 0:
				var direction = to_local(NavAgent.get_next_path_position()).normalized().round()
				auto_move(direction)
		elif CanAct:
			act()
		else:
			IsCurrentTurn = false
			_on_turn_end(self)
			EndTurn.emit()
	else:
		var directions: Vector2 = Input.get_vector("left", "right", "up", "down")
		
		if directions == Vector2.ZERO:
			return

		if !IsMoving && RemainingSpeed > 0:
			manual_move(directions)
		
		if RemainingSpeed == 0 && !CanAct:
			set_process(false)
			set_physics_process(false)
			IsCurrentTurn = false
			_on_turn_end(self)
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

func auto_move(direction: Vector2i) -> void:
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

func manual_move(direction: Vector2i) -> void:
	var currentTile: Vector2i = Level.Tiles.local_to_map(self.global_position)
	var targetTile: Vector2i = Vector2(
		currentTile.x + direction.x,
		currentTile.y + direction.y
	)
	var tileData: TileData = Level.Tiles.get_cell_tile_data(targetTile)
	
	Raycast.target_position = direction * 48
	Raycast.force_raycast_update()
	
	if Raycast.is_colliding():
		return
	if (tileData.get_custom_data("Walkable") == false):
		return
	
	IsMoving = true
	self.global_position = Level.Tiles.map_to_local(currentTile)
	Level.MovingTile.global_position = Level.Tiles.map_to_local(targetTile)
	
	RemainingSpeed -= 1

func act() -> void:
	var dir: Vector2
	var rotation_deg: int
	var basic_ability = Abilities.get_node_or_null("BasicAttack") as AbilityBase
	
	for i in 4:
		match i:
			0:
				dir = Vector2.UP
				rotation_deg = 270
			1:
				dir = Vector2.DOWN
				rotation_deg = 90
			2: 
				dir = Vector2.RIGHT
				rotation_deg = 0
			3:
				dir = Vector2.LEFT
				rotation_deg = 180
		
		Raycast.target_position = dir * 48
		Raycast.force_raycast_update()
		var collider = Raycast.get_collider()
		if collider is not ActorBase:
			continue
		if collider.IsAlly == self.IsAlly:
			continue
		if basic_ability:
			basic_ability.use_on_self(rotation_deg)
			return
	
	CanAct = false

func _on_turn_start(node: ActorBase) -> void:
	if node != self:
		return
	
	heal(HealthRegen)
	change_mana(ManaRegen)
	
	var target = _get_target()
	if target == null:
		target = Player
	
	var navObstacle = get_node("Combat/NavigationObstacle2D") as NavigationObstacle2D
	navObstacle.affect_navigation_mesh = false
	
	Level.NavRegion.bake_navigation_polygon()
	await Level.NavRegion.bake_finished
	
	NavAgent.target_position = target.global_position
	
	IsCurrentTurn = true
	RemainingSpeed = Speed

func _on_turn_end(_node: ActorBase) -> void:
	var navObstacle = get_node("Combat/NavigationObstacle2D") as NavigationObstacle2D
	navObstacle.affect_navigation_mesh = true

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
