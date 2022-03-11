extends AbstractState

export var attack_delay: float = 0.7
export var attack_distance: float = 2.5

var attack_towards: Vector3

func bounce_animation():
	parent.bounce_override = - 1.8
	$BouceAnimationTween.interpolate_property(parent, "bounce_override_factor", 0.0, 1.0, .7)
	$BouceAnimationTween.start()
	yield($BouceAnimationTween, "tween_all_completed")
	$BouceAnimationTween.remove_all()
	if state_machine.state.name != "Attacking":
		$BouceAnimationTween.interpolate_property(parent, "bounce_override_factor", 1.0, 0.0, .4)
		$BouceAnimationTween.start()
		return
	$BouceAnimationTween.interpolate_property(parent, "bounce_override", parent.bounce_override, .7, .3)
	$BouceAnimationTween.interpolate_property(parent, "bounce_override_factor", 1.0, 0.0, .8)
	$BouceAnimationTween.start()


func process(_delta: float, first_time_entering: bool):
	if first_time_entering:
		bounce_animation()
#		$PrepareAttack.emitting = true
		yield(get_tree().create_timer(0.55 * attack_delay), "timeout")
		if state_machine.state.name != "Attacking":
			return
		attack_towards = Game.player.global_transform.origin
		yield(get_tree().create_timer(0.2 * attack_delay), "timeout")
		if state_machine.state.name != "Attacking":
			return
		# if player is still close to the enemy, execute the attack

		parent.get_node("Hitbox").set_deferred("monitorable", true)
		parent = parent as WaterEnemy
		parent.AIR_FRICTION = 1.0
		var jump_power := 1200.0
		var jump_acc : Vector3 = (attack_towards - parent.global_transform.origin).normalized() * jump_power
		jump_acc.y = jump_power * .8
		parent.add_acceleration(jump_acc)
		# jump towards position
		parent.get_node("JumpSound").play()
		
		
		# delay needed for some reason
		yield(get_tree().create_timer(.6), "timeout")
		if state_machine.state.name != "Attacking":
			return
		parent.get_node("Hitbox").set_deferred("monitorable", false)
		yield(get_tree().create_timer(.1), "timeout")
		if state_machine.state.name != "Attacking":
			return
		state_machine.transition_deferred("Idle")


func _on_Hitbox_body_entered(body):
	if body is Player:
		parent = parent as WaterEnemy
		parent.velocity = Vector3.ZERO
		var back_drop_power := 400.0
		var direction := Game.player.global_transform.origin.direction_to(parent.global_transform.origin)
		direction.y = 0.0
		direction = direction.normalized()
		var back_drop_acc := direction * back_drop_power
		back_drop_acc.y = back_drop_power * 1.5
		parent.add_acceleration(back_drop_acc)


func _on_Hitbox_area_entered(area):
	_on_Hitbox_body_entered(area.get_parent())
