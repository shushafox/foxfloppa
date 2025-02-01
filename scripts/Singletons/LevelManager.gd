extends Node


func change_scene(levelPath: String) -> void:
	call_deferred("_deferred_change_scene", levelPath)

func _deferred_change_scene(levelPath: String) -> void:
	get_tree().current_scene.free()
	
	var level_resource = ResourceLoader.load(levelPath)
	var level_instance = level_resource.instantiate()
	get_tree().get_root().add_child(level_instance)
	get_tree().current_scene = level_instance
	
func update_objective(newObj: String) -> void:
	var level_instance = get_tree().current_scene
	level_instance.UI.Objective.text = newObj

func add_loot(itemName: String) -> void:
	var level_instance = get_tree().current_scene
	level_instance.UI.Items.add_item(itemName)

func remove_loot(itemName: String) -> void:
	var level_instance = get_tree().current_scene
	var item_count = level_instance.UI.Items.get_item_count()
	for i in item_count:
		if level_instance.UI.Items.get_item_text(i) == itemName:
			level_instance.UI.Items.remove_item(i)
			break
