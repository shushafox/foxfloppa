extends AbilityBase

func affect(target: ActorBase) -> void:
	var chance = Actor.Aim - target.Evasion
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var resultChange = rng.randf_range(0, 100)
	
	if resultChange > chance:
		return
	
	match DamageModifier:
		_Stats.Aim:
			target.hurt(BaseDamage * (((Actor.Aim / 10) - 5)))
		_Stats.Armor:
			target.hurt(BaseDamage * Actor.Armor)
		_Stats.Speed:
			target.hurt(BaseDamage * Actor.Speed)
		_Stats.Evasion:
			target.hurt(BaseDamage * (Actor.Evasion / 5))
