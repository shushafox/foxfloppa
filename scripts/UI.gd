extends Control

@onready var Title: Label = $Title
@onready var Speed: Label = $Stats/Speed
@onready var Health: Label = $Stats/Health
@onready var Mana: Label = $Stats/Mana
@onready var Damage: Label = $Stats/Damage
@onready var Tooltip: Label = $ToolTip

func _process(delta: float) -> void:
	size = get_window().size / 2
	position = -(size / 2)

func reset_turns() -> void:
	Title.text = ""

func set_turns(turn: int) -> void:
	Title.text = "Turn: " + str(turn)

func set_stat(stat: String, max: float, current: float) -> void:
	var value: String
	stat = stat.to_lower()
	
	if max == 0:
		value = str(current)
	else:
		value = str(current) + "/" + str(max)
	
	match stat:
		"speed":
			Speed.text = "Speed: " + value
		"health":
			Health.text = "Health: " + value
		"mana":
			Mana.text = "Mana: " + value
		"damage":
			Damage.text = "Damage: " + value
