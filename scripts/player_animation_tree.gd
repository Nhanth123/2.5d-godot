extends AnimationTree

enum {
	Normal,
	Airborne,
	Dead
}

var state

func changeStateToAirborne():
	state = Airborne

func changeStateToNormal():
	state = Normal

func checkIfStateIsAirborne():
	return state == Airborne
