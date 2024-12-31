extends ActorBase

signal NpcInterract

var IsMoving: bool = false

@onready var Level: Node2D = get_parent()

@export var BaseSpeed = 400

func _ready() -> void:
	Dialogic.timeline_started.connect(set_physics_process.bind(false))
	Dialogic.timeline_started.connect(set_process_input.bind(false))

	Dialogic.timeline_ended.connect(set_physics_process.bind(true))
	Dialogic.timeline_ended.connect(set_process_input.bind(true))

func _physics_process(delta: float) -> void:
	var directions: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	if(!Level.IsCombat):
		Level.MovingTile.visible = false
		
		velocity = directions * BaseSpeed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		Level.MovingTile.visible = true
		
		if(!IsMoving):
			move(directions)
		else:
			if (Level.MovingTile.global_position == self.global_position):
				IsMoving = false
				return
			
			self.global_position = self.global_position.move_toward(Level.MovingTile.global_position, 10)
		
	if Input.is_action_pressed("ui_accept"):
			NpcInterract.emit()

func move(direction: Vector2i):
	var currentTile: Vector2i = Level.Tiles.local_to_map(self.global_position)
	var targetTile: Vector2i = Vector2(
		currentTile.x + direction.x,
		currentTile.y + direction.y
	)
	var tileData: TileData = Level.Tiles.get_cell_tile_data(targetTile)
	
	if (tileData.get_custom_data("Walkable") == false):
		return
	
	IsMoving = true
	self.global_position = Level.Tiles.map_to_local(currentTile)
	Level.MovingTile.global_position = Level.Tiles.map_to_local(targetTile)
