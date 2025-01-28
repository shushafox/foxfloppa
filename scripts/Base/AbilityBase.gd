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
		actors.filter(func(a: ActorBase): a.IsAlly)
	if TargetType == _TargetType.Enemy:
		actors.filter(func(a: ActorBase): !a.IsAlly)
	
	for actor in actors:
		affect(actor)

func _create_shape(shape_type: String, size: Vector2, position: Vector2 = Vector2.ZERO) -> CollisionShape2D:
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
	collider.position = position
	return collider

func _get_targets(target: Vector2i) -> Array[ActorBase]:
	var collider_position: Vector2 = target
	var space_state: PhysicsDirectSpaceState2D = Actor.get_world_2d().direct_space_state
	
	var shape: Shape2D
	var shape_transform: Transform2D
	var query = PhysicsShapeQueryParameters2D.new()
	
	match RangeType:
		_RangeType.Circle:
			shape = CircleShape2D.new()
			shape.radius = RangeValue * 24
			shape_transform = Transform2D.IDENTITY.translated(collider_position)
		_RangeType.Square:
			shape = RectangleShape2D.new()
			shape.size = Vector2((RangeValue + 1) * 48, (RangeValue + 1) * 48)
			shape_transform = Transform2D.IDENTITY.translated(collider_position)
		_RangeType.Line:
			shape = RectangleShape2D.new()
			var direction = (collider_position - Actor.global_position).normalized()
			var length = 48 * RangeValue
			shape.size = Vector2(length, 48)
			shape_transform = Transform2D.IDENTITY.rotated(direction.angle()).translated(collider_position + direction * length/2)
		_RangeType.Cross:
			var cross_shape = ConvexPolygonShape2D.new()
			var arm_length = RangeValue * 24
			var arm_width = 24  # Half of 48px tile size
			
			# Cross points (thick + shape)
			cross_shape.points = PackedVector2Array([
				Vector2(-arm_width, -arm_length),  # Top left
				Vector2(arm_width, -arm_length),   # Top right
				Vector2(arm_width, -arm_width),    # Right top
				Vector2(arm_length, -arm_width),   # Right end
				Vector2(arm_length, arm_width),    # Right bottom
				Vector2(arm_width, arm_width),     # Bottom right
				Vector2(arm_width, arm_length),    # Bottom end
				Vector2(-arm_width, arm_length),   # Bottom left
				Vector2(-arm_width, arm_width),    # Left bottom
				Vector2(-arm_length, arm_width),   # Left end
				Vector2(-arm_length, -arm_width),  # Left top
				Vector2(-arm_width, -arm_width)    # Top left inner
			])
			shape = cross_shape
			query.transform = Transform2D.IDENTITY.translated(collider_position)
	
	query.shape = shape
	query.transform = shape_transform
	query.collision_mask = 0b1  # Only first layer
	query.exclude = [self]  # Dont hit yourself
	
	var actors: Array[ActorBase] = []
	for result in space_state.intersect_shape(query):
		if result.collider is ActorBase:
			actors.append(result.collider)
	
	return actors
#endregion
