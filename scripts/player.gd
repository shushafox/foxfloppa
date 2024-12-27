extends CharacterBody2D
signal hit

@export var speed = 400

@onready var Level = get_parent()

signal onNpcInterract()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_input():
	if(Level.IsPeaceMode):
		var input_direction = Input.get_vector("left", "right", "up", "down")
		velocity = input_direction * speed
		
		if Input.is_action_pressed("ui_accept"):
			onNpcInterract.emit()
	else:
		velocity = Vector2.ZERO

func _physics_process(delta):
	get_input()
	move_and_slide()
	
func _ready() -> void:
	Dialogic.timeline_started.connect(set_physics_process.bind(false))
	Dialogic.timeline_started.connect(set_process_input.bind(false))

	Dialogic.timeline_ended.connect(set_physics_process.bind(true))
	Dialogic.timeline_ended.connect(set_process_input.bind(true))
