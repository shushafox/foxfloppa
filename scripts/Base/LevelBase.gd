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
var IsAiming: bool = false

var TurnOrder: Array[TurnElement] = []

var TurnNumber: int = 0

var TempAbility: AbilityBase = null
var AbilityRange: Node2D = null

const RangeTemplate: String = "res://Scenes/Templates/Ability/Range.tscn"
#endregion

#region Functions
func bind_signals() -> void:
	for child: ActorBase in Npcs.get_children():
		CombatEnded.connect(child._on_combat_end)
		CombatStarted.connect(child._on_combat_start)
		TurnStarted.connect(child._on_turn_start)
		child.ActorRemoved.connect(_on_actor_removed)
		child.ActorUpdated.connect(_on_actor_updated)
		child.EndTurn.connect(_on_turn_end)
	
	CombatEnded.connect(Player._on_combat_end)
	CombatStarted.connect(Player._on_combat_start)
	TurnStarted.connect(Player._on_turn_start)
	Player.ActorRemoved.connect(_on_actor_removed)
	Player.ActorUpdated.connect(_on_actor_updated)
	Player.EndTurn.connect(_on_turn_end)
	
	UI.EndTurn.connect(_on_turn_end)
	
	Dialogic.signal_event.connect(_on_dialogic_signal)

func end_combat() -> void:
	IsCombat = false
	MovingTile.visible = false
	CombatEnded.emit()
	UI.end_combat()
	
	TurnOrder.clear()
	
	_remove_tile_outline()

func start_combat() -> void:
	IsCombat = true
	MovingTile.visible = true
	CombatStarted.emit()
	
	# Gather everyone for combat
	for child: ActorBase in Npcs.get_children():
		if child.IsAutoamted:
			var turnElement = TurnElement.new()
			turnElement.Actor = child
			TurnOrder.append(turnElement)
	
	# Randomize enemy order
	randomize()
	TurnOrder.shuffle()
	
	# Add player
	var playerElem = TurnElement.new()
	playerElem.Actor = Player	
	TurnOrder.push_front(playerElem)
	
	UI.start_combat(TurnOrder)
	
	_add_tile_outline()
	
	TurnStarted.emit(Player)
	Camera.follow_target = Player

func aim() -> void:
	if !TempAbility:
		return
	
	if AbilityRange != null:
		var mouse_pos = get_local_mouse_position()
		var snapped_pos = Tiles.map_to_local(Tiles.local_to_map(mouse_pos))
		AbilityRange.position = snapped_pos + Vector2(-20,-20)
	else:
		AbilityRange = load(RangeTemplate).instantiate()
		match TempAbility.RangeType:
			AbilityBase._RangeType.Cross:
				AbilityRange.use("cross", TempAbility.RangeValue)
				add_child(AbilityRange)
			AbilityBase._RangeType.Circle:
				AbilityRange.use("circle", TempAbility.RangeValue)
				add_child(AbilityRange)
			AbilityBase._RangeType.Square:
				AbilityRange.use("square", TempAbility.RangeValue)
				add_child(AbilityRange)
			AbilityBase._RangeType.Line:
				AbilityRange.use("line", TempAbility.RangeValue)
				add_child(AbilityRange)
			_:
				print("ERROR: unrecognized ability range type")

func start_aiming(ability: AbilityBase) -> void:
	IsAiming = true
	TempAbility = ability

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
	await get_tree().create_timer(1).timeout
	TurnNumber += 1
	
	var Actor: ActorBase = TurnOrder[TurnNumber % TurnOrder.size()].Actor
	
	Camera.follow_target = Actor
	await get_tree().create_timer(1).timeout
	TurnStarted.emit(Actor)

func _on_actor_removed(node: ActorBase) -> void:
	if IsCombat:
		var element: TurnElement
		
		for turnElement in TurnOrder:
			if turnElement.Actor == node:
				element = turnElement
		
		element.Portrait.queue_free()
		element.Card.queue_free()

func _on_actor_updated(node: ActorBase) -> void:
	if IsCombat:
		var element: TurnElement
		
		for turnElement in TurnOrder:
			if turnElement.Actor == node:
				element = turnElement
		
		UI.update_actor(element)
	else:
		var element: TurnElement
		element.Actor = node
		UI.update_actor(element)

#endregion

#region Classes

class TurnElement:
	var Actor: ActorBase
	var Portrait: TextureRect
	var Card: NinePatchRect

#endregion
