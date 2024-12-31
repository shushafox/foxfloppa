extends Node2D

class_name LevelBase

#region Signals
signal CombatStarted
signal CombatEnded
#endregion

#region Base nodes
@onready var Player: ActorBase = get_node("Player")
#Map
@onready var Tiles:TileMapLayer = get_node("Map/TileMap")
@onready var OutlineTiles: TileMapLayer = get_node("Map/OutlineMap")
#Misc
@onready var OverworldCamera: Camera2D = get_node("Misc/OverworldCamera")
@onready var MovingTile: Sprite2D = get_node("Misc/MovingSprite")
#Folders
@onready var Npcs: Node2D = get_node("Npcs")
@onready var Triggers: Node2D = get_node("Triggers")
#endregion

#region Variables
@export var LevelName: String = ""

var IsCombat: bool = false
#endregion

#region Functions
func bind_signals() -> void:
	for child: ActorBase in Npcs.get_children():
		CombatEnded.connect(child._on_combat_end)
		CombatStarted.connect(child._on_combat_start)
	
	CombatEnded.connect(Player._on_combat_end)
	CombatStarted.connect(Player._on_combat_start)

func end_combat() -> void:
	CombatEnded.emit()
	
	_remove_tile_outline()

func start_combat() -> void:
	CombatStarted.emit()
	
	_add_tile_outline()

func _add_tile_outline() -> void:
	OutlineTiles.clear()
	for tile in Tiles.get_used_cells():
		OutlineTiles.set_cell(Vector2(tile.x,tile.y), 0, Vector2(0,0), 0)

func _remove_tile_outline() -> void:
	OutlineTiles.clear()
#endregion
