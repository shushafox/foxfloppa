extends ActorBase

signal NpcInterract

var isMoving: bool = false

@onready var Level: Node2D = get_parent()
@onready var MovingSprite: Sprite2D = $MovingSptire

@export var BaseSpeed = 400

func _ready() -> void:
	Dialogic.timeline_started.connect(set_physics_process.bind(false))
	Dialogic.timeline_started.connect(set_process_input.bind(false))

	Dialogic.timeline_ended.connect(set_physics_process.bind(true))
	Dialogic.timeline_ended.connect(set_process_input.bind(true))

func _physics_process(delta: float) -> void:
	var directions: Vector2 = get_input()
	
	if(Autoload.IsPeaceMode):
		MovingSprite.visible = false
		
		velocity = directions * BaseSpeed
		move_and_slide()
		
		if Input.is_action_pressed("ui_accept"):
			NpcInterract.emit()
	else:
		velocity = Vector2.ZERO
		MovingSprite.visible = true
		move(directions)

func get_input() -> Vector2:
	return Input.get_vector("left", "right", "up", "down")

func move(direction: Vector2i):
	var currentTile: Vector2i = Level.Tiles.local_to_map(self.global_position)
	var targetTile: Vector2i = Vector2(
		currentTile.x + direction.x,
		currentTile.y + direction.y
	)
	var tileData: TileData = Level.Tiles.get_cell_tile_data(targetTile)
	
	if (tileData.get_custom_data("Walkable") == false):
		return
	
	isMoving = true
	self.global_position = Level.Tiles.map_to_local(targetTile)
	MovingSprite.global_position = Level.Tiles.map_to_local(currentTile)
