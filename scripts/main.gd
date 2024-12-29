extends Node2D

@onready var Tiles:TileMapLayer = get_node("Map/TileMap")
@onready var OutlineTiles: TileMapLayer = get_node("Map/OutlineMap")

var OutlineTileId: int = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	if(Autoload.IsDay):
		Tiles.modulate = Color.WHITE
	else:
		Tiles.modulate = Color.BLUE
	
	if Autoload.IsPeaceMode:
		OutlineTiles.clear()
		
		if !Autoload.IsDay:
			Tiles.modulate = Color.BLUE
		else:
			Tiles.modulate = Color.WHITE
	else:
		add_outline_for_tiles(Tiles, OutlineTiles)

func add_outline_for_tiles(Tiles: TileMapLayer, OutlineTiles: TileMapLayer):
	OutlineTiles.clear()
	var a = Tiles.get_used_cells()
	for tile in Tiles.get_used_cells():
		OutlineTiles.set_cell(Vector2(tile.x,tile.y), OutlineTileId, Vector2(0,0), 0)
