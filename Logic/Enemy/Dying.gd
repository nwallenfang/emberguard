extends AbstractState

func process(_delta: float, first_time_entering: bool):
	if first_time_entering:
		parent.get_node("DeathParticles").emitting = true
		yield(get_tree().create_timer(1.3), "timeout")
		parent.queue_free()
