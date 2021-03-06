extends AbstractState

export var stop_distance: float = 3.0
export var spotted_acc := 80.0

var target_position_xz:  Vector2

func process(_delta: float, first_time_entering: bool):
	# move fast towards player for now when the player is spotted
	if first_time_entering:
		$SpottedPlayerParticles.emitting = true
		
		
	#var player_pos: Vector2 = Vector2(Game.player.global_transform.origin.x, Game.player.global_transform.origin.z)
	var player_pos = parent.get_node("ScentSearcher").get_target_position()
	player_pos = Vector2(player_pos.x, player_pos.z)
	var done_moving: bool = state_machine.move_towards(player_pos, stop_distance, spotted_acc)
	
	
	if done_moving:
		# attack or smth
		state_machine.transition_deferred("MagicAttack")
