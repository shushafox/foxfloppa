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
@onready var NavRegion: NavigationRegion2D = get_node("Map/NavigationRegion2D")
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
var CurrentCharacter: ActorBase = null
var AbilityRange: Node2D = null
var CastRange: Node2D = null

const RangeTemplate: String = "res://scenes/templates/ability/range.tscn"
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
	UI.update_actor(TurnElement.newElement(Player))
	
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
	CurrentCharacter = Player
	
	UI.start_combat(TurnOrder)
	
	_add_tile_outline()
	
	TurnStarted.emit(Player)
	Camera.follow_target = Player

func aim() -> void:
	if !TempAbility:
		return
	
	if AbilityRange != null:
		if TempAbility.IsDetached:
			var mouse_pos = get_local_mouse_position()
			var snapped_pos = Tiles.map_to_local(Tiles.local_to_map(mouse_pos)) + Vector2.ONE * -24
			AbilityRange.position = snapped_pos
			CastRange.position = CurrentCharacter.position + Vector2.ONE * -24
		else:
			var mouse_pos = get_local_mouse_position()
			var dir = CurrentCharacter.position.direction_to(mouse_pos).normalized().round()
			var snapped_pos = Tiles.map_to_local(Tiles.local_to_map(TempAbility.Actor.position))
			AbilityRange.position = snapped_pos
			
			if TempAbility.RangeType == AbilityBase._RangeType.Line:
				match dir:
					Vector2(1,0),Vector2(1,1):
						AbilityRange.rotation_degrees = 0
						AbilityRange.position += Vector2(24, -24)
					Vector2(0,1),Vector2(-1,1):
						AbilityRange.rotation_degrees = 90
						AbilityRange.position += Vector2(24, 24)
					Vector2(-1,0),Vector2(-1,-1):
						AbilityRange.rotation_degrees = 180
						AbilityRange.position += Vector2(-24, 24)
					Vector2(0,-1),Vector2(1,-1):
						AbilityRange.rotation_degrees = 270
						AbilityRange.position += Vector2(-24, -24)
			
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if TempAbility.IsDetached:
				TempAbility.use_on_target(AbilityRange.position)
			else: 
				TempAbility.use_on_self(AbilityRange.rotation_degrees)
			
			AbilityRange.queue_free()
			
			if CastRange:
				CastRange.queue_free()
			TempAbility = null
			IsAiming = false
		
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			AbilityRange.queue_free()
			CastRange.queue_free()
			TempAbility = null
			IsAiming = false
	else: # if we didnt create range 
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
		
		if TempAbility.IsDetached:
			CastRange = load(RangeTemplate).instantiate()
			CastRange.use("circle", TempAbility.CastRange, Color(0,255,0,0.2), false)
			add_child(CastRange)

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
	
	if Actor.IsAlly && !Actor.IsAutoamted:
		CurrentCharacter = Actor
	else:
		CurrentCharacter = null
	
	if !TurnOrder.any(func(a: TurnElement): return !a.Actor.IsAlly):
		end_combat()
	else:
		UI.advance_turns()
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
		
		if !TurnOrder.any(func(a: TurnElement): return !a.Actor.IsAlly):
			end_combat()
		else:
			TurnOrder.remove_at(TurnOrder.find(element))

func _on_actor_updated(node: ActorBase) -> void:
	if IsCombat:
		var element: TurnElement = TurnElement.new()
		
		for turnElement in TurnOrder:
			if turnElement.Actor == node:
				element = turnElement
		
		UI.update_actor(element)
	else:
		var element: TurnElement = TurnElement.new()
		element.Actor = node
		UI.update_actor(element)

#endregion

#region Classes

class TurnElement:
	var Actor: ActorBase
	var Portrait: TextureRect
	var Card: NinePatchRect
	
	static func newElement(node: ActorBase) -> TurnElement:
		var result: TurnElement = new()
		result.Actor = node
		return result

#endregion
