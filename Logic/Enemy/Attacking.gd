extends AbstractState

export var attack_delay: float = 0.7
export var attack_distance: float = 2.5

var attack_towards: Vector3

func process(_delta: float, first_time_entering: bool):
	# TODO 
	if first_time_entering:
#		$PrepareAttack.emitting = true
		yield(get_tree().create_timer(0.7 * attack_delay), "timeout")
		attack_towards = Game.player.global_transform.origin
		yield(get_tree().create_timer(0.3 * attack_delay), "timeout")
		# if player is still close to the enemy, execute the attack
		
#		var dist_to_player = Game.player.global_transform.origin.distance_to(parent.global_transform.origin)

		parent.global_transform.origin = attack_towards
		# jump towards position
		# not for now
		
		
		
		# delay needed for some reason
		yield(get_tree().create_timer(0.1), "timeout")
		state_machine.transition_deferred("Idle")
