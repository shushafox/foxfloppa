extends Control

signal EndTurn

@onready var Objective: Label = $Base/Objective
@onready var EscapeMenu = $Base/EscMenu
@onready var InventoryMenu = $Base/InventoryMenu
@onready var Items = $Base/InventoryMenu/Items
@onready var ListMenu = $Base/ListMenu
@onready var Combat: Control = $Combat
@onready var Peace: Control = $Peace
@onready var Portraits: HBoxContainer = $Combat/TurnOrder/TurnOrderPortraits
@onready var Cards: VBoxContainer = $Combat/TurnOrder/TurnOrderCards
@onready var Level: LevelBase = get_parent().get_parent().get_parent()

var PortraitNode: PackedScene = load("res://Scenes/UI/Portrait.tscn")
var ActorCardNode: PackedScene = load("res://Scenes/UI/ActorCard.tscn")
var DefaultRim: Texture2D = load("res://Assets/outline.png")
var DefaultPortrait: Texture2D = load("res://Assets/Roi/Roi_Portrait.png")

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

func start_combat(elements: Array[LevelBase.TurnElement]) -> void:
	Combat.visible = true
	Peace.visible = false
	
	for element in elements:
		var portrait = PortraitNode.instantiate()
		var card = ActorCardNode.instantiate()
		var actor = element.Actor
		
		element.Portrait = portrait
		element.Card = card
		
		portrait.Rim = actor.DisplayPortraitRim if !actor.DisplayPortraitRim == null else DefaultPortrait
		portrait.Portrait = actor.DisplayPortrait if !actor.DisplayPortrait == null else DefaultRim
		
		card.Rim = portrait.Rim
		card.Portrait = portrait.Portrait
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

func update_actor(element: LevelBase.TurnElement) -> void:
	if element.Actor.name == "Player":
		Peace.get_node("ActorCard").refresh(element.Actor)
		
		if element.Card != null:
			element.Card.refresh(element.Actor)
	else:
		element.Card.refresh(element.Actor)

func _on_menu_pressed() -> void:
	EscapeMenu.visible = !EscapeMenu.visible

func _on_inventory_pressed() -> void:
	InventoryMenu.visible = !InventoryMenu.visible
	
func _on_end_turn_pressed() -> void:
	if Level.Player.IsCurrentTurn == true:
		EndTurn.emit()

func _on_ability_pressed() -> void:
	ListMenu.visible = !ListMenu.visible
	
	var List = ListMenu.get_node("Scroll/Vbox")
	for child in List.get_children():
		child.free()
	
	#TODO: Вот тут надо бы убрать игрока и сделать так чтоб использовался конкретный персонаж на ком сейчас управлене
	var abilities = Level.Player.get_ability_list()
	
	for ability in abilities:
		var button = Button.new()
		button.text = ability.AbilityName
		button.pressed.connect(_trigger_ability.bind(button.text))
		List.add_child(button)

func _on_attack_pressed() -> void:
	pass # Replace with function body.

func _trigger_ability(AbilityName: String) -> void:
	#TODO: тут та же проблема что выше, надо уйти от игрока в общему персонажу (но пока похуй)
	var abilities = Level.Player.get_ability_list()
	var result: AbilityBase
	
	for ability in abilities:
		if ability.name == AbilityName:
			result = ability
	
	Level.start_aiming(result)
	
	ListMenu.visible = !ListMenu.visible
