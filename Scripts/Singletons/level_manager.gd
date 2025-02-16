extends Node

func change_scene(levelPath: String) -> void:
	call_deferred("_deferred_change_scene", levelPath)

func _deferred_change_scene(levelPath: String) -> void:
	get_tree().current_scene.free()
	
	var level_resource = ResourceLoader.load(levelPath)
	var level_instance = level_resource.instantiate()
	get_tree().get_root().add_child(level_instance)
	get_tree().current_scene = level_instance

func obj_interaction_resolver(objname: String) -> bool:
	var level_instance = get_tree().current_scene
	var object = level_instance.find_child(objname)
	return object.InteractedWith

# HUH: а может тут поставить передачу аргумента, а то вот ты потрогал ящик
# он поинтеракчен, потрогал ещё, больше не поинтеракчен
func obj_interaction_switch(objname: String) -> void:
	var level_instance = get_tree().current_scene
	var object = level_instance.find_child(objname)
	object.InteractedWith = true

func update_objective(newObj: String) -> void:
	var level_instance = get_tree().current_scene as LevelBase
	level_instance.UI.Objective.text = newObj

func add_loot(itemName: String) -> void:
	var level_instance = get_tree().current_scene
	level_instance.UI.Items.add_item(itemName)

func find_loot(itemName: String) -> bool:
	var level_instance = get_tree().current_scene
	var item_count = level_instance.UI.Items.get_item_count()
	for i in item_count:
		if level_instance.UI.Items.get_item_text(i) == itemName:
			return true
	return false

func remove_loot(itemName: String) -> void:
	var level_instance = get_tree().current_scene
	var item_count = level_instance.UI.Items.get_item_count()
	for i in item_count:
		if level_instance.UI.Items.get_item_text(i) == itemName:
			level_instance.UI.Items.remove_item(i)
			break
