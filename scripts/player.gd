extends ActorBase

signal NpcInterract

var IsMoving: bool = false

@onready var Level: Node2D = get_parent()
@onready var Raycast: RayCast2D = $Combat/RayCast2D
@export var BaseSpeed = 250

func _ready() -> void:
	Dialogic.timeline_started.connect(set_process.bind(false))
	Dialogic.timeline_started.connect(set_process_input.bind(false))

	Dialogic.timeline_ended.connect(set_process.bind(true))
	Dialogic.timeline_ended.connect(set_process_input.bind(true))

func _process(_delta: float) -> void:
	_calculate_turn_abilities()
	
	var directions: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	if(!Level.IsCombat):		
		velocity = directions * BaseSpeed
		move_and_slide()
	else:
		if directions == Vector2.ZERO:
			return
		
		if(!IsMoving):
			
			if RemainingSpeed > 0:
				move(directions)
		else:
			if (Level.MovingTile.global_position == self.global_position):
				IsMoving = false
				return
			
			self.global_position = self.global_position.move_toward(Level.MovingTile.global_position, 10)
	
	_animate()
	
	if Input.is_action_pressed("ui_accept"):
		NpcInterract.emit()
	if Input.is_action_pressed("End"):
		EndTurn.emit()
	elif !CanMove && !CanAct:
		EndTurn.emit()

func move(direction: Vector2i):
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
	_snap_to_grid()
	if node != self:
		return
	RemainingSpeed = Speed

func _snap_to_grid() -> void:
	var currentTile: Vector2i = Level.Tiles.local_to_map(self.global_position)
	self.global_position = Level.Tiles.map_to_local(currentTile)

func _animate() -> void:
	if velocity > Vector2.ZERO:
		AnimatedSprite.flip_h = false
		AnimatedSprite.play("running")
	elif velocity < Vector2.ZERO:
		AnimatedSprite.flip_h = true
		AnimatedSprite.play("running")
	else:
		AnimatedSprite.play("idle")
