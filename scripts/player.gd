extends ActorBase

signal NpcInterract
signal ObjInterract

var IsMoving: bool = false

@onready var Level: LevelBase = get_parent()
@onready var Raycast: RayCast2D = $Combat/RayCast2D

@export var BaseSpeed = 250

func _ready() -> void:
	Dialogic.timeline_started.connect(set_process.bind(false))
	Dialogic.timeline_started.connect(set_process_input.bind(false))

	Dialogic.timeline_ended.connect(set_process.bind(true))
	Dialogic.timeline_ended.connect(set_process_input.bind(true))

func _physics_process(delta: float) -> void:
	if Level.IsCombat && IsMoving:
		if (Level.MovingTile.global_position == self.global_position):
			IsMoving = false
			return
		else:
			self.global_position = self.global_position.move_toward(Level.MovingTile.global_position, 1)

func _process(_delta: float) -> void:
	Level.UI.set_stat("speed", Speed, RemainingSpeed)
	
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
	Level.UI.set_stat("speed", Speed, RemainingSpeed)
	
	if Input.is_action_pressed("ui_accept"):
		NpcInterract.emit()
		ObjInterract.emit()
	if Input.is_action_pressed("End"):
		EndTurn.emit()
	if RemainingSpeed == 0:
		set_process(false)
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
	if node != self:
		return
	
	RemainingSpeed = Speed
	_snap_to_grid()
	
	set_process(true)

func _snap_to_grid() -> void:
	var currentTile: Vector2i = Level.Tiles.local_to_map(self.global_position)
	self.global_position = Level.Tiles.map_to_local(currentTile)

func _animate() -> void:
	if velocity != Vector2.ZERO:
		AnimatedSprite.play("running")
		if velocity.x > 0:
			AnimatedSprite.flip_h = false
		elif velocity.x < 0:
			AnimatedSprite.flip_h = true
	else:
		AnimatedSprite.play("idle")
