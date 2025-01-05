extends Control

@onready var Objective: Label = $Objective
@onready var Portraits: HBoxContainer = $TurnOrder/TurnOrderPortraits
@onready var Cards: VBoxContainer = $TurnOrder/TurnOrderCards
@onready var TurnOrder: Control = $TurnOrder
@onready var CombatActions: VBoxContainer = $CombatActios

const PortraitNodePath: String = "res://Scenes/UI/Portrait.tscn"
const ActorCardNodePath: String = "res://Scenes/UI/ActorCard.tscn"

const DefaultRim: String = "res://Assets/outline.png"
const DefaultPortrait: String = "res://Assets/angry.png"

func _process(_delta: float) -> void:
	size = get_window().size / 2
	position = -(size / 2)

func end_combat() -> void:
	TurnOrder.visible = false
	CombatActions.visible = false
	
	var cards = Cards.get_children()
	var portraits = Portraits.get_children()
	
	for card in cards:
		card.queue_free()
	for portrait in portraits:
		portrait.queue_free()

func start_combat(actors: Array[ActorBase]) -> void:
	TurnOrder.visible = true
	CombatActions.visible = true
	
	var portrait = load(PortraitNodePath)
	var card = load(ActorCardNodePath)
	
	for actor in actors:
		var portraitPath = actor.DisplayPortrait
		var rimPath = actor.DisplayPortraitRim
		
		if portraitPath.is_empty():
			portraitPath = DefaultPortrait
		if rimPath.is_empty():
			rimPath = DefaultRim
		
		portrait.Rim = rimPath
		portrait.Portrait = portraitPath
		
		card.Rim = rimPath
		card.Portrait = portraitPath
		card.MaxHealth = actor.MaxHealth
		card.MaxMana = actor.MaxMana
		card.Health = actor.Health
		card.Mana = actor.Mana
		
		Portraits.add_child(portrait.instantiate())
		Cards.add_child(card.instantiate())

func advance_turns() -> void:
	var portrait = Portraits.get_child(0)
	Portraits.move_child(portrait, Portraits.get_child_count() - 1)
	
	var card = Cards.get_child(0)
	Cards.move_child(card, Cards.get_child_count() - 1)
