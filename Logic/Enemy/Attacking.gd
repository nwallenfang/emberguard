extends AbstractState

export var attack_delay: float = 0.7
export var attack_distance: float = 2.5

var attack_towards: Vector3

func process(_delta: float, first_time_entering: bool):
	# TODO 
	if first_time_entering:
#		$PrepareAttack.emitting = true
		yield(get_tree().create_timer(0.55 * attack_delay), "timeout")
		attack_towards = Game.player.global_transform.origin
		yield(get_tree().create_timer(0.2 * attack_delay), "timeout")
		# if player is still close to the enemy, execute the attack

		parent.get_node("Hitbox").set_deferred("monitorable", true)
		parent = parent as WaterEnemy
		parent.AIR_FRICTION = 1.0
		var jump_power := 1200.0
		var jump_acc : Vector3 = (attack_towards - parent.global_transform.origin).normalized() * jump_power
		jump_acc.y = jump_power * .8
		parent.add_acceleration(jump_acc)
		# jump towards position
		# not for now
		
		
		
		# delay needed for some reason
		yield(get_tree().create_timer(2.5), "timeout")
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
