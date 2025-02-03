extends Node

class_name AbilityBase

#region Types
enum _RangeType {Cross, Circle, Square}
enum _TargetType {Ally, Enemy, Everyone}
enum _Stats {Armor, Aim, Evasion, Speed}
#endregion

#region Exports
@export var AbilityName: String = ""
@export var IsDetached: bool = false
@export var TargetType: _TargetType = _TargetType.Enemy
@export var RangeType: _RangeType = _RangeType.Cross
@export var RangeValue: int = 1
@export var BaseDamage: int = 1
@export var DamageModifier: _Stats = _Stats.Aim
#endregion

@onready var Actor: ActorBase = get_parent().get_parent()

#region Functions

func use_on_self() -> void:
	_use(Actor.global_position)

func use_on_target(targetPosition: Vector2i) -> void:
	_use(targetPosition)

func affect(target: ActorBase) -> void:
	if !can_hit(target.Evasion):
		return
	
	target.hurt(get_damage())

func can_hit(targetEvasion: int) -> bool:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var chance = Actor.Aim - targetEvasion
	var resultChance = rng.randf_range(0, 100)
	
	return resultChance <= chance

func get_damage() -> int:
	match DamageModifier:
		_Stats.Aim:
			return BaseDamage * ((Actor.Aim / 10) - 5)
		_Stats.Armor:
			return BaseDamage * Actor.Armor
		_Stats.Speed:
			return BaseDamage * Actor.Speed
		_Stats.Evasion:
			return BaseDamage * (Actor.Evasion / 5)
		_:
			return BaseDamage

func _use(targetPosition: Vector2i) -> void:
	var actors: Array[ActorBase] = _get_targets(targetPosition)
	
	if TargetType == _TargetType.Ally:
		actors = actors.filter(func(a: ActorBase): return a.IsAlly)
	if TargetType == _TargetType.Enemy:
		actors = actors.filter(func(a: ActorBase): return !a.IsAlly)
	
	for actor in actors:
		affect(actor)

func _get_targets(target: Vector2i) -> Array[ActorBase]:
	var shape: Shape2D
	var shape_transform: Transform2D
	var query = PhysicsShapeQueryParameters2D.new()
	var collider_position: Vector2 = (target / 48) * 48 + Vector2i(24, 24)  # Ensuring snapping to the center of a tile
	var space_state: PhysicsDirectSpaceState2D = Actor.get_world_2d().direct_space_state
	
	match RangeType:
		_RangeType.Circle:
			shape = CircleShape2D.new()
			shape.radius = RangeValue * 24
			shape_transform = Transform2D.IDENTITY.translated(collider_position)
		_RangeType.Square:
			shape = RectangleShape2D.new()
			shape.size = Vector2((RangeValue + 1) * 48, (RangeValue + 1) * 48)
			shape_transform = Transform2D.IDENTITY.translated(collider_position)
		_RangeType.Cross:
			var arm_length = RangeValue * 48
			var arm_width = 48
			shape = RectangleShape2D.new()
			shape.size = Vector2(arm_length * 2 + arm_width, arm_length * 2 + arm_width)
			shape_transform = Transform2D.IDENTITY.translated(collider_position)
	
	query.shape = shape
	query.transform = shape_transform
	query.collision_mask = 0b1  # Only first layer
	query.exclude = [self]  # Don't hit yourself
	
	var actors: Array[ActorBase] = []
	for result in space_state.intersect_shape(query):
		if result.collider is ActorBase:
			
			if RangeType == _RangeType.Cross:
				var offset: Vector2 = result.collider.global_position - collider_position
				if offset != Vector2.ZERO && abs(offset.x) == abs(offset.y):  
					continue
			
			actors.append(result.collider)
	
	return actors

#endregion
