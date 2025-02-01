extends Node

func change_scene(levelPath: String) -> void:
	call_deferred("_deferred_change_scene", levelPath)

func _deferred_change_scene(levelPath: String) -> void:
	get_tree().current_scene.free()
	
	var level_resource = ResourceLoader.load(levelPath)
	var level_instance = level_resource.instantiate()
	get_tree().get_root().add_child(level_instance)
	get_tree().current_scene = level_instance
	level_instance.UI.Objective.text = "welcome to " + level_instance.LevelName
	
	
