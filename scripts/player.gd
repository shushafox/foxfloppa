extends CharacterBody2D
signal hit

@export var speed = 400

signal onNpcInterract()

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
	if Input.is_action_pressed("ui_accept"):
		onNpcInterract.emit()

func _physics_process(delta):
	get_input()
	move_and_slide()
	
func _ready() -> void:
	Dialogic.timeline_started.connect(set_physics_process.bind(false))
	Dialogic.timeline_started.connect(set_process_input.bind(false))

	Dialogic.timeline_ended.connect(set_physics_process.bind(true))
	Dialogic.timeline_ended.connect(set_process_input.bind(true))
