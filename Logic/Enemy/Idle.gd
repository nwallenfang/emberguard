extends AbstractState

export var IDLE_TIME = 0.15
func process(_delta: float, first_time_entering: bool):
	if first_time_entering:
		parent.get_node("DetectionArea").set_deferred("monitoring", false)
		yield(get_tree().create_timer(IDLE_TIME * randf()), "timeout")
		parent.get_node("DetectionArea").set_deferred("monitoring", true)
		state_machine.call_deferred("transition_to_random_state")
