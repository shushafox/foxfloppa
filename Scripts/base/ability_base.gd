extends Node

class_name AbilityBase

#region Types
enum _RangeType {Cross, Circle, Square, Line}
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
@export var ManaCost: int = 1
@export var CastRange: int = 10 #in cells
#endregion

@onready var Actor: ActorBase = get_parent().get_parent()

#region Functions

func use_on_self(rotationDegrees: int = 0) -> void:
	_use(Actor.position, rotationDegrees)

func use_on_target(targetPosition: Vector2i, rotationDegrees: int = 0) -> void:
	_use(targetPosition, rotationDegrees)

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

func _use(targetPosition: Vector2i, rotationDegrees: int = 0) -> void:
	var actors: Array[ActorBase] = _get_targets(targetPosition, rotationDegrees)
	
	if TargetType == _TargetType.Ally:
		actors = actors.filter(func(a: ActorBase): return Actor.IsAlly == a.IsAlly)
	if TargetType == _TargetType.Enemy:
		actors = actors.filter(func(a: ActorBase): return Actor.IsAlly != a.IsAlly)
	
	if Actor.Mana < ManaCost:
		return
	if Actor.position.distance_to(targetPosition) > CastRange * 48:
		return
	
	Actor.change_mana(-ManaCost)
	Actor.CanAct = false
	
	for actor in actors:
		affect(actor)

func _get_targets(target: Vector2, rotationDegrees: int = 0) -> Array[ActorBase]:
	var shape: Shape2D
	var shape_transform: Transform2D
	const TILE_SIZE = 48
	var collider_position = target * TILE_SIZE / TILE_SIZE + Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
	
	var query = PhysicsShapeQueryParameters2D.new()
	var space_state: PhysicsDirectSpaceState2D = Actor.get_world_2d().direct_space_state
	
	match RangeType:
		_RangeType.Circle:
			shape = CircleShape2D.new()
			shape.radius = RangeValue * TILE_SIZE / 2
			shape_transform = Transform2D.IDENTITY.translated(collider_position)

		_RangeType.Square:
			shape = RectangleShape2D.new()
			shape.size = Vector2((RangeValue + 1) * TILE_SIZE, (RangeValue + 1) * TILE_SIZE)
			shape_transform = Transform2D.IDENTITY.translated(collider_position)

		_RangeType.Line:
			shape = RectangleShape2D.new()
			var rotation_rad = deg_to_rad(rotationDegrees)
			var direction = Vector2.RIGHT.rotated(rotation_rad)
			var length = TILE_SIZE * RangeValue
			var start_offset = direction * (TILE_SIZE / 2)
			var center_offset = direction * (length / 2)
			
			if rotationDegrees == 0 || rotationDegrees == 180:
				shape.size = Vector2(length, TILE_SIZE)
			elif rotationDegrees == 90 || rotationDegrees == 270:
				shape.size = Vector2(TILE_SIZE, length)
			
			shape_transform = Transform2D(rotation_rad, collider_position + start_offset + center_offset)

		_RangeType.Cross:
			var arm_length = RangeValue * TILE_SIZE
			var arm_width = TILE_SIZE
			shape = RectangleShape2D.new()
			shape.size = Vector2(arm_length * 2 + arm_width, arm_length * 2 + arm_width)
			shape_transform = Transform2D.IDENTITY.translated(collider_position)
	
	query.shape = shape
	query.transform = shape_transform
	query.collision_mask = 0b1  # Make this configurable if needed
	query.exclude = [self]  # Don't hit yourself
	
	var actors: Array[ActorBase] = []
	for result in space_state.intersect_shape(query):
		if result.collider is ActorBase:
			if RangeType == _RangeType.Cross:
				var offset: Vector2 = result.collider.global_position - target
				if offset != Vector2.ZERO and abs(offset.x) == abs(offset.y):  
					continue
			
			actors.append(result.collider)
	
	return actors

#endregion
