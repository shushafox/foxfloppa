extends Node

var GlobalCounter:int = 1
var IsDay: bool = false

func EvilGuyTimelinePicker() -> String:
	if (GlobalCounter < -2):
		return "angi"
	else:
		return "testOne"
