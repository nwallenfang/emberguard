extends AbstractState

export var IDLE_TIME = 0.1
func process(_delta: float, first_time_entering: bool):
	if first_time_entering:
#		parent.get_node("DetectionArea").set_deferred("monitoring", false)
#		parent.get_node("DetectionArea").set_deferred("monitorable", false)
#		parent.get_node("DetectionArea").monitoring = false
#		parent.get_node("DetectionArea").monitorable = false
		parent.get_node("DetectionArea").translation += Vector3(0,20,0)
		yield(get_tree().create_timer(.1 + IDLE_TIME * randf()), "timeout")
		parent.get_node("DetectionArea").translation += Vector3(0,-20,0)
#		parent.get_node("DetectionArea").set_deferred("monitoring", true)
#		parent.get_node("DetectionArea").set_deferred("monitorable", true)
#		print(parent.get_node("DetectionArea").monitoring)
#		print(parent.get_node("DetectionArea").monitorable)
#		parent.get_node("DetectionArea").monitoring = true
#		parent.get_node("DetectionArea").monitorable = true
		if state_machine.state.name == "Idle":
			state_machine.call_deferred("transition_to_random_state")
#		yield(get_tree().create_timer(.05), "timeout")
#		print(parent.get_node("DetectionArea").monitoring)
#		print(parent.get_node("DetectionArea").monitorable)
#		print(parent.get_node("DetectionArea").overlaps_area(Game.player.get_node("Hurtbox")))
#		print(parent.get_node("DetectionArea").get_overlapping_areas())
