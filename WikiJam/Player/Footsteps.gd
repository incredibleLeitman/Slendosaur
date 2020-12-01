extends Spatial


onready var steps = [
	get_node("Footstep")
]


func play_footstep():
	#Logger.trace("Footstep")
	steps[0].play()