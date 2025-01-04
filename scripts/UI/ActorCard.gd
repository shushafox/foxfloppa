extends TextureRect

@export var Rim: String
@export var Portrait: String
@export var MaxHealt: int
@export var MaxMana: int
@export var Health: int
@export var Mana: int

@onready var HealthBar: ProgressBar = $HBoxContainer/VBoxContainer/Health
@onready var ManaBar: ProgressBar = $HBoxContainer/VBoxContainer/Mana
@onready var PortraitNode: TextureRect = $HBoxContainer/Portrait

func _ready() -> void:
	HealthBar.max_value = MaxHealt
	HealthBar.value = Health
	ManaBar.max_value = MaxMana
	ManaBar.value = Mana
	
	PortraitNode.Portrait = Portrait
	PortraitNode.Rim = Rim
