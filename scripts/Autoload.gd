extends Node

var GlobalCounter:int = 1
var IsDay: bool = true
var EvilTalkedTo: bool = false

func NpcTimeLineResolver(name: String) -> String:
	match name:
		"evil": return _EvilGuy()
		"corvi": return _Corvi()
		_: return "" # defaut

func _EvilGuy() -> String:
	if (GlobalCounter < -2):
		return "angi"
	else:
		return "testOne"	

func _Corvi() -> String:
	if (EvilTalkedTo == true):
		return "corvi_2"
	else:
		return "corvi_1"
		
