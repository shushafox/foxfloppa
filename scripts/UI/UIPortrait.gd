extends TextureRect

@export var Rim: String
@export var Portrait: String

@onready var RimNode: TextureRect = $"."
@onready var PortraitNode: TextureRect = $Portrait

const DefaultRim: String = "res://Assets/outline.png"
const DefaultPortrait: String = "res://Assets/Roi/Roi_Portrait.png"

func _ready() -> void:
	if Portrait.is_empty():
		Portrait = DefaultPortrait
	if Rim.is_empty():
		Rim = DefaultRim
	
	RimNode.texture = load(Rim)
	PortraitNode.texture = load(Portrait)

func reload() -> void:
	if Portrait.is_empty():
		Portrait = DefaultPortrait
	if Rim.is_empty():
		Rim = DefaultRim
	
	RimNode.texture = load(Rim)
	PortraitNode.texture = load(Portrait)
