extends Node

var is_open = false
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	close()
	 # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Open Menu"):
		print("WE ARE OPEN")
		if is_open:
			close()
		else:
			open()
	
func _on_menu_pressed():
	print("WE ARE OPEN")
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
