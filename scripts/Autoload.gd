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
		"Sign_2_1": return _Sign_2_1()
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
		
func _Sign_2_1():
	return "sign_2_1"
#endregion
