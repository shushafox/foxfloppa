extends CharacterBody2D

class_name ActorBase

#region Signals
signal EndTurn
#endregion

#region Combat stats
@export var MaxHealth: int = 10
@export var MaxMana: int = 5
@export var Armor: int = 0
@export var Aim: int = 75
@export var Evasion: int = 0
@export var Speed: int = 3
@export var Damage: int = 4

var Health: float = MaxHealth
var Mana: float = MaxMana
var RemainingSpeed: int = Speed

@export var IsAlly: bool = true
@export var IsAutoamted: bool = true

var IsMoving: bool = false
var CanAct: bool = true
var CanMove: bool = true
#endregion

#region Non Combat attributes
@export var DisplayName: String = ""
@export var DisplaySprite: String = ""
@export var DisplayPortrait: String = "" 
@export var DisplayPortraitRim: String = ""
#endregion

#region PreLoad nodes
@onready var AnimatedSprite: AnimatedSprite2D = $AnimatedSprite
@onready var Collision: CollisionShape2D = $Collision
@onready var Combat: Node2D = $Combat
@onready var Peace: Node2D = $Peace
#endregion

#region Base functions
func _set_sprite() -> void:
	pass

func _on_combat_start() -> void:
	$Peace.process_mode = Node.PROCESS_MODE_DISABLED
	$Combat.process_mode = Node.PROCESS_MODE_INHERIT
	
	self.velocity = Vector2.ZERO

func _on_combat_end() -> void:
	$Peace.process_mode = Node.PROCESS_MODE_INHERIT
	$Combat.process_mode = Node.PROCESS_MODE_DISABLED

func _calculate_turn_abilities() -> void:
	if RemainingSpeed == 0:
		CanMove = false

func _on_turn_start(node: ActorBase) -> void:
	if node != self:
		return
		
	EndTurn.emit()

func _on_turn_end(node: ActorBase)  -> void:
	return
#endregion
