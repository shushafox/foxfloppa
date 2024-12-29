extends Node

#region Counters
var GlobalCounter:int = 1
#endregion

#region Switches
var IsDay: bool = true
var IsPeaceMode: bool = true
#endregion

#region Complex data
var NpcsTalkedTo = {
	"Evil": false,
	"Corvi": false
}
#endregion

#region Resolvers
func NpcTimeLineResolver(name: String) -> String:
	match name:
		"Evil": return _EvilGuy()
		"Corvi": return _Corvi()
		_: return "" # defaut

func _EvilGuy() -> String:
	if (GlobalCounter < -2):
		return "angi"
	else:
		return "testOne"

func _Corvi() -> String:
	if (NpcsTalkedTo["Evil"] == true):
		return "corvi_2"
	else:
		return "corvi_1"
#endregion
