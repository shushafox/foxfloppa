extends CharacterBody2D

class_name ActorBase

#region Combat stats
@export var MaxHealth: int = 10
@export var MaxMana: int = 5

var Health: float = MaxHealth
var Mana: float = MaxMana

@export var Armor: int = 0
@export var Aim: int = 75
@export var Evasion: int = 0
@export var Speed: int = 3
@export var Damage: int = 4

@export var IsAlly: bool = true
@export var IsAutoamted: bool = true
#endregion

#region Non Combat attributes
@export var DisplayName: String = ""
@export var DisplaySprite: String = ""
@export var DisplayPortrait: String = "" 
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

func _on_combat_end() -> void:
	$Peace.process_mode = Node.PROCESS_MODE_INHERIT
	$Combat.process_mode = Node.PROCESS_MODE_DISABLED
#endregion
