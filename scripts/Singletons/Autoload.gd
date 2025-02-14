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
var BoxesLooted = {
	"L2Box1": false,
	"L2Box2": false
}

#endregion

#region Resolvers

func NpcTimeLineResolver(npcName: String) -> String:
	match npcName:
		#level 1 dialogue
		"Evil": return _EvilGuy()
		"Corvi": return _Corvi()
		"Sign_1_1": return "Sign_1_1"
		#level 2 dialogue
		"L2Box1": return "L2Box1"
		"L2Box2": return "L2Box2"
		"Sign_2_1": return "sign_2_1"
		"GatePirate": return "L2GatePirate"
		"L2BoxBoots": return "L2BoxBoots"
		
		
		_: return "" # defaut
		

func _EvilGuy() -> String:
	if (GlobalCounter < -11112):
		return "angi"
	else:
		return "testOne"

func _Corvi() -> String:
	if (NpcsTalkedTo["Evil"] == true):
		return "corvi_2"
	else:
		return "corvi_1"

#endregion
