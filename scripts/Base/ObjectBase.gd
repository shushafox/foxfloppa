extends CharacterBody2D

class_name ObjectBase

#region Non Combat attributes
@export var DisplayName: String = ""
@export var DisplaySprite: String = ""
#endregion

#region PreLoad nodes
@onready var AnimatedSprite: AnimatedSprite2D = $AnimatedSprite
@onready var Collision: CollisionShape2D = $Collision
#endregion

#region Base functions
func _set_sprite() -> void:
	pass
