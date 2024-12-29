extends Node

class_name LevelBase

#region Base nodes
@onready var Tiles:TileMapLayer = get_node("Map/TileMap")
@onready var OutlineTiles: TileMapLayer = get_node("Map/OutlineMap")
@onready var OverworldCamera: Camera2D = get_node("Misc/OverworldCamera")
@onready var Played: ActorBase = get_node("Player")
#endregion

#region Misc
@export var LevelName: String = ""
#endregion

func _on_combat_started():
	OverworldCamera.IsFocused = false

func _add_tile_outline() -> void:
	for tile in Tiles.get_used_cells():
		OutlineTiles.set_cell(Vector2(tile.x,tile.y), 0, Vector2(0,0), 0)
