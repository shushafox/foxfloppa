extends TextureRect

@export var Rim: String
@export var Portrait: String

@onready var RimNode: TextureRect = $"."
@onready var PortraitNode: TextureRect = $Portrait

func _ready() -> void:
	var rimTexture = load(Rim) as Texture
	var portraitTexture = load(Portrait) as Texture
	
	RimNode.texture = rimTexture
	PortraitNode.texture = portraitTexture
