extends NinePatchRect

@export var Rim: Texture2D
@export var Portrait: Texture2D
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

func refresh(actor: ActorBase) -> void:
	HealthBar.value = actor.Health
	HealthBar.max_value = actor.MaxHealth
	HealthLabel.text = str(actor.Health) + "/" + str(actor.MaxHealth)
	
	ManaBar.value = actor.Mana
	ManaBar.max_value = actor.MaxMana
	ManaLabel.text = str(actor.Mana) + "/" + str(actor.MaxMana)
