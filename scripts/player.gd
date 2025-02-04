extends ActorBase

signal Interract

@export var BaseSpeed = 250
@export var can_talk: bool = true

func _ready() -> void:
	Level = get_parent()
	
	Dialogic.timeline_started.connect(set_process.bind(false))
	Dialogic.timeline_started.connect(set_process_input.bind(false))

	Dialogic.timeline_ended.connect(set_process.bind(true))
	Dialogic.timeline_ended.connect(set_process_input.bind(true))
	Dialogic.timeline_started.connect(_on_dialogic_started)
	Dialogic.timeline_ended.connect(_on_dialogic_ended)


func _physics_process(_delta: float) -> void:
	if Level.IsCombat && IsMoving:
		if (Level.MovingTile.global_position == self.global_position):
			IsMoving = false
			return
		else:
			self.global_position = self.global_position.move_toward(Level.MovingTile.global_position, 1)

func _process(_delta: float) -> void:	
	var directions: Vector2 = Input.get_vector("left", "right", "up", "down")
	if(!Level.IsCombat):		
		velocity = directions * BaseSpeed
		move_and_slide()
	else:
		if(!IsMoving):
			if directions == Vector2.ZERO:
				return
			if RemainingSpeed > 0:
				move(directions)
	
	_animate()
	
	if can_talk and Input.is_action_pressed("ui_accept"):
		Interract.emit()
		
	if RemainingSpeed == 0:
		set_process(false)
		IsCurrentTurn = false
		EndTurn.emit()
		
		
func _on_dialogic_started():
	AnimatedSprite.play("idle")
	
func _on_dialogic_ended():
	can_talk = false
	await get_tree().create_timer(0.2).timeout
	can_talk = true
	pass

func move(direction: Vector2i) -> void:
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

func _on_turn_start(node: ActorBase) -> void:
	if node != self:
		return
	
	IsCurrentTurn = true
	RemainingSpeed = Speed
	
	set_process(true)

func _animate() -> void:
	if velocity != Vector2.ZERO:
		AnimatedSprite.play("running")
		if velocity.x > 0:
			AnimatedSprite.flip_h = false
		elif velocity.x < 0:
			AnimatedSprite.flip_h = true
	else:
		AnimatedSprite.play("idle")
