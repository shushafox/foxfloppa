extends CharacterBody2D

class_name ActorBase

#region Signals
signal EndTurn
signal ActorRemoved(node: ActorBase)
signal ActorUpdated(node: ActorBase)
#endregion

#region Combat stats
@export var MaxHealth: int = 10
@export var HealthRegen: int = 0
@export var MaxMana: int = 5
@export var ManaRegen: int = 1
@export var Armor: int = 0
@export var Aim: int = 75
@export var Evasion: int = 0
@export var Speed: int = 3
@export var Damage: int = 4
@export var VisionRadius: int = 10

var Health: float = MaxHealth
var Mana: float = MaxMana
var RemainingSpeed: int = Speed

@export var IsAlly: bool = true
@export var IsAutoamted: bool = true

var IsCurrentTurn: bool = false
var IsMoving: bool = false
var IsActing: bool = false
var CanAct: bool = true
var CanMove: bool = true
#endregion

#region Non Combat attributes
@export var DisplayName: String = ""
@export var DisplaySprite: Texture2D
@export var DisplayPortrait: Texture2D
@export var DisplayPortraitRim: Texture2D
#endregion

#region PreLoad nodes
@onready var AnimatedSprite: AnimatedSprite2D = $AnimatedSprite
@onready var Collision: CollisionShape2D = $Collision
@onready var Abilities: Node2D = $Abilities
@onready var Combat: Node2D = $Combat
@onready var Peace: Node2D = $Peace
@onready var TargetArea: Area2D = $Combat/TargetArea
@onready var Raycast: RayCast2D = $Combat/RayCast
@onready var Level: LevelBase #Npcs and Player load it differently
#endregion

#region Base functions

func hurt(value: int) -> void:
	value -= Armor
	
	if value < 0:
		value = 0
	
	Health -= value
	
	if Health <= 0:
		ActorRemoved.emit(self)
		self.queue_free()
	else:
		ActorUpdated.emit(self)

func heal(value: int) -> void:
	Health += value
	
	if Health > MaxHealth:
		Health = MaxHealth
	
	ActorUpdated.emit(self)

func change_mana(value: int) -> void:
	Mana += value
	
	if Mana > MaxMana:
		Mana = MaxMana
	if Mana < 0:
		Mana = 0
	
	ActorUpdated.emit(self)

func get_ability_list() -> Array[AbilityBase]:
	var result: Array[AbilityBase]
	for ability in Abilities.get_children():
		if ability is AbilityBase:
			result.append(ability)
	return result

func _set_targeting_area() -> void:
	TargetArea.get_node("CollisionShape").shape.radius = 46 * VisionRadius

func _set_sprite() -> void:
	pass

func _snap_to_grid() -> void:
	var currentTile: Vector2i = Level.Tiles.local_to_map(self.global_position)
	self.global_position = Level.Tiles.map_to_local(currentTile)

func _on_combat_start() -> void:
	_snap_to_grid()
	
	$Peace.process_mode = Node.PROCESS_MODE_DISABLED
	$Peace.visible = false
	$Combat.process_mode = Node.PROCESS_MODE_INHERIT
	$Combat.visible = true
	
	self.velocity = Vector2.ZERO

func _on_combat_end() -> void:
	$Peace.process_mode = Node.PROCESS_MODE_INHERIT
	$Peace.visible = true
	$Combat.process_mode = Node.PROCESS_MODE_DISABLED
	$Combat.visible = false
	
	self.set_process(true)

func _calculate_turn_abilities() -> void:
	if RemainingSpeed == 0:
		CanMove = false
	else:
		CanMove = true

func _on_turn_start(node: ActorBase) -> void:
	if node != self:
		return
	
	heal(HealthRegen)
	change_mana(ManaRegen)
	
	EndTurn.emit()

func _on_turn_end(_node: ActorBase)  -> void:
	return

func _create_shape(shape_type: String, size: Vector2, location: Vector2 = Vector2.ZERO) -> CollisionShape2D:
	var shape: Shape2D
	match shape_type:
		"circle":
			shape = CircleShape2D.new()
			shape.radius = size.x / 2
		"rectangle":
			shape = RectangleShape2D.new()
			shape.size = size
	
	var collider: CollisionShape2D = CollisionShape2D.new()
	collider.shape = shape
	collider.position = location
	return collider

func _get_target() -> ActorBase:
	var result: ActorBase
	
	TargetArea.get_node("CollisionShape").shape.radius = 46 * VisionRadius
	
	for body in TargetArea.get_overlapping_bodies():
		if body is ActorBase && body.IsAlly != self.IsAlly:
			result = body
	
	return result

#endregion
