extends TextureRect

@export var Rim: Texture2D
@export var Portrait: Texture2D

@onready var RimNode: TextureRect = $"."
@onready var PortraitNode: TextureRect = $Portrait

var DefaultRim: Texture2D = load("res://assets/outline.png")
var DefaultPortrait: Texture2D = load("res://assets/roi/Roi_Portrait.png")

func _ready() -> void:
	update_textures()

func reload() -> void:
	update_textures()

func update_textures() -> void:
	RimNode.texture = Rim if Rim else DefaultRim
	PortraitNode.texture = Portrait if Portrait else DefaultPortrait
