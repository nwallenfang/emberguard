extends AbstractState

func process(_delta: float, first_time_entering: bool):
	if first_time_entering:
		if parent.has_node("Hurtbox"):
			parent.get_node("Hurtbox").set_deferred("monitorable", false)
			parent.get_node("Hurtbox").set_deferred("monitoring", false)
		if parent.has_node("Hitbox"):
			parent.get_node("Hitbox").set_deferred("monitorable", false)
			parent.get_node("Hitbox").set_deferred("monitoring", false)
		parent.get_node("DeathParticles").emitting = true
#		if not parent.has_node("Placeholder"):
#			printerr("can't find mesh to make invis when dying, fix me in Dying.gd")
#		else:
		if parent.has_node("Viking"):
			parent.get_node("Viking").visible = false
		elif parent.has_node("magician"):
			parent.get_node("magician").visible = false
		
		parent.get_node("DyingSound").play()
		$DyingTimer.start(1.3)


func _on_DyingTimer_timeout() -> void:
	parent.queue_free()
