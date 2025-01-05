extends Node

var is_open = false

func _ready() -> void:
	close()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Open Menu"):
		if is_open:
			close()
		else:
			open()

func _on_menu_pressed():
	if is_open:
		close()
	else:
		open()

func open():
	self.visible = true
	is_open = true

func close():
	self.visible = false 
	is_open = false
