extends AbstractState

func process(_delta: float, first_time_entering: bool):
	if first_time_entering:
		parent.get_node("Hitbox").set_deferred("monitorable", false)
		parent.get_node("Hitbox").set_deferred("monitoring", false)
		parent.get_node("DeathParticles").emitting = true
		if not parent.has_node("Placeholder"):
			printerr("can't find mesh to make invis when dying, fix me in Dying.gd")
		else:
			parent.get_node("Placeholder").visible = false
		$DyingTimer.start(1.3)


func _on_DyingTimer_timeout() -> void:
	parent.queue_free()
