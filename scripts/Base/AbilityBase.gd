extends Node

class_name AbilityBase

#region Types
enum _RangeType {Cross, Circle, Square, Line}
enum _TargetType {Ally, Enemy, Everyone}
enum _Stats {Armor, Aim, Evasion, Speed}
#endregion

#region Exports
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
	var collider_position: Vector2 = Actor.Level.Tiles.map_to_local(target)
	var area: Area2D = Area2D.new()
	var shape_size: Vector2
	var position_offset: Vector2 = Vector2.ZERO

	match RangeType:
		_RangeType.Circle:
			shape_size = Vector2(RangeValue * 48, RangeValue * 48)
			area.add_child(_create_shape("circle", shape_size))
		_RangeType.Square:
			shape_size = Vector2(RangeValue * 48, RangeValue * 48)
			area.add_child(_create_shape("rectangle", shape_size))
		_RangeType.Line:
			position_offset = (collider_position - Actor.global_position).normalized().round() * 48 * (RangeValue - 1)
			shape_size = Vector2(48, 48) + position_offset.abs()
			area.add_child(_create_shape("rectangle", shape_size, position_offset))
		_RangeType.Cross:
			var shape_size_v = Vector2(48, (RangeValue + 2) * 48)
			var shape_size_h = Vector2((RangeValue + 2) * 48, 48)
			area.add_child(_create_shape("rectangle", shape_size_v))
			area.add_child(_create_shape("rectangle", shape_size_h))

	Actor.add_child(area)
	area.force_update_transform()
	
	var actors: Array[ActorBase] = []
	for body in area.get_overlapping_bodies():
		if body is ActorBase:
			actors.append(body)
	
	area.queue_free() 
	return actors
#endregion
