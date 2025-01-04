extends Node2D

class_name LevelBase

#region Signals
signal CombatStarted
signal CombatEnded

signal TurnStarted(node: ActorBase)
#endregion

#region Base nodes
@onready var Camera: PhantomCamera2D = get_node("PhantomCamera")
@onready var Player: ActorBase = get_node("Player")
#Map
@onready var Tiles:TileMapLayer = get_node("Map/TileMap")
@onready var OutlineTiles: TileMapLayer = get_node("Map/OutlineMap")
#Misc
@onready var MovingTile: Sprite2D = get_node("Misc/MovingSprite")
@onready var UI: Control = get_node("Misc/OverworldCamera/UI")
#Folders
@onready var Npcs: Node2D = get_node("Npcs")
@onready var Triggers: Node2D = get_node("Triggers")
#endregion

#region Variables
@export var LevelName: String = ""

var IsCombat: bool = false
var IsPlayersTurn: bool = false
var TurnOrder: Array[ActorBase] = []
var TurnNumber: int = 0
#endregion

#region Functions
func bind_signals() -> void:
	for child: ActorBase in Npcs.get_children():
		CombatEnded.connect(child._on_combat_end)
		CombatStarted.connect(child._on_combat_start)
		TurnStarted.connect(child._on_turn_start)
		child.EndTurn.connect(_on_turn_end)
	
	CombatEnded.connect(Player._on_combat_end)
	CombatStarted.connect(Player._on_combat_start)
	TurnStarted.connect(Player._on_turn_start)
	Player.EndTurn.connect(_on_turn_end)
	
	Dialogic.signal_event.connect(_on_dialogic_signal)

func end_combat() -> void:
	IsCombat = false
	MovingTile.visible = false
	CombatEnded.emit()
	
	TurnOrder.clear()
	
	_remove_tile_outline()

func start_combat() -> void:
	IsCombat = true
	MovingTile.visible = true
	CombatStarted.emit()
	
	# Gather everyone for combat
	for child: ActorBase in Npcs.get_children():
		if child.IsAutoamted:
			TurnOrder.append(child)
	
	# Randomize enemy order
	randomize()
	TurnOrder.shuffle()
	TurnOrder.push_front(Player)
	
	_add_tile_outline()
	
	TurnStarted.emit(Player)
	Camera.follow_target = Player

func _add_tile_outline() -> void:
	OutlineTiles.clear()
	for tile in Tiles.get_used_cells():
		OutlineTiles.set_cell(Vector2(tile.x,tile.y), 0, Vector2(0,0), 0)

func _remove_tile_outline() -> void:
	OutlineTiles.clear()

func _on_dialogic_signal(argument: String):
	if argument == "StartCombat":
		start_combat()

func _on_turn_end() -> void:
	TurnNumber += 1
	
	var Actor: ActorBase = TurnOrder[TurnNumber % TurnOrder.size()]

	TurnStarted.emit(Actor)
	Camera.follow_target = Actor
#endregion
