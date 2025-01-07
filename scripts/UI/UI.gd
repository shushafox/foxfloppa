extends Control

signal EndTurn

@onready var Objective: Label = $Base/Objective
@onready var EscapeMenu = $Base/SubMenus/EscMenu
@onready var Combat: Control = $Combat
@onready var Peace: Control = $Peace
@onready var Portraits: HBoxContainer = $Combat/TurnOrder/TurnOrderPortraits
@onready var Cards: VBoxContainer = $Combat/TurnOrder/TurnOrderCards
@onready var Level: LevelBase = get_parent().get_parent().get_parent()

const PortraitNodePath: String = "res://Scenes/UI/Portrait.tscn"
const ActorCardNodePath: String = "res://Scenes/UI/ActorCard.tscn"

const DefaultRim: String = "res://Assets/outline.png"
const DefaultPortrait: String = "res://Assets/angry.png"

func _process(_delta: float) -> void:
	size = get_window().size / 2
	position = -(size / 2)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Open Menu"):
		EscapeMenu.visible = !EscapeMenu.visible

func end_combat() -> void:
	Combat.visible = false
	Peace.visible = true
	
	var cards = Cards.get_children()
	var portraits = Portraits.get_children()
	
	for card in cards:
		card.queue_free()
	for portrait in portraits:
		portrait.queue_free()

func start_combat(actors: Array[ActorBase]) -> void:
	Combat.visible = true
	Peace.visible = false
	
	for actor in actors:
		var portrait = load(PortraitNodePath).instantiate()
		var card = load(ActorCardNodePath).instantiate()
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
		
		Portraits.add_child(portrait)
		Cards.add_child(card)

func advance_turns() -> void:
	var portrait = Portraits.get_child(0)
	Portraits.move_child(portrait, Portraits.get_child_count() - 1)
	
	var card = Cards.get_child(0)
	Cards.move_child(card, Cards.get_child_count() - 1)

func _on_menu_pressed() -> void:
	EscapeMenu.visible = !EscapeMenu.visible

func _on_end_turn_pressed() -> void:
	if Level.Player.IsCurrentTurn == true:
		EndTurn.emit()

func _on_ability_pressed() -> void:
	pass
