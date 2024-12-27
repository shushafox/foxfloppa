extends Node

var GlobalCounter:int = 1
var IsDay: bool = true

func NpcTimeLineResolver(name: String) -> String:
	match name:
		"evil": return _EvilGuy()
		_: return "" # defaut

func _EvilGuy() -> String:
	if (GlobalCounter < -2):
		return "angi"
	else:
		return "testOne"	
