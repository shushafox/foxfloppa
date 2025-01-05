extends NinePatchRect

@export var Rim: String
@export var Portrait: String
@export var MaxHealth: int
@export var MaxMana: int
@export var Health: int
@export var Mana: int

@onready var HealthBar: ProgressBar = $HBoxContainer/VBoxContainer/Health/ProgressBar
@onready var HealthLabel: Label = $HBoxContainer/VBoxContainer/Health
@onready var ManaBar: ProgressBar = $HBoxContainer/VBoxContainer/Mana/ProgressBar
@onready var ManaLabel: Label = $HBoxContainer/VBoxContainer/Mana
@onready var PortraitNode: TextureRect = $HBoxContainer/Portrait

func _ready() -> void:
	HealthBar.max_value = MaxHealth
	HealthBar.value = Health
	HealthLabel.text = str(Health,"/",MaxHealth)
	ManaBar.max_value = MaxMana
	ManaBar.value = Mana
	ManaLabel.text = str(Mana,"/",MaxMana)
	
	PortraitNode.Portrait = Portrait
	PortraitNode.Rim = Rim
	PortraitNode.reload()
