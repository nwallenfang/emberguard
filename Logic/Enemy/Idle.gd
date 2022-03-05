extends AbstractState

export var IDLE_TIME = 0.2
func process(_delta: float, first_time_entering: bool):
	print("idle")
	if first_time_entering:
		yield(get_tree().create_timer(IDLE_TIME * (randi() % 3)), "timeout")
		state_machine.call_deferred("transition_to_random_state")
