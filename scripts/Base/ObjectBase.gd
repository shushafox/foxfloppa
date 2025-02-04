extends StaticBody2D

class_name ObjectBase

#region Non Combat attributes
@export var DisplayName: String = ""
@export var DisplaySprite: String = ""
@export var InteractedWith: bool = false 
#endregion

#region PreLoad nodes
@onready var Player = get_parent().get_parent().get_node("Player")
@onready var AnimatedSprite: AnimatedSprite2D = $AnimatedSprite
@onready var Collision: CollisionShape2D = $Collision
@onready var Combat: Node2D = $Combat
@onready var Peace: Node2D = $Peace
@onready var PeaceCollider = $Peace/DetectionArea
@onready var CombatCollider = $Combat/DetectionArea
#endregion

#region Functions
func get_collider() -> Area2D:
	if Combat.process_mode == Node.ProcessMode.PROCESS_MODE_DISABLED:
		return PeaceCollider
	else:
		return CombatCollider
#endregion
