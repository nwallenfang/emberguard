extends AbstractState

export var stop_distance: float = 0
export var run_acc := 60.0

var run_direction:  Vector2

func process(_delta: float, first_time_entering: bool):
	if first_time_entering:
		if $RunTimer.is_stopped():
			$RunTimer.start(2.2 if Game.main_game_running else 6.0)
			if parent.has_node("Hitbox"):
				parent.get_node("Hitbox").set_deferred("monitorable", false)
	var target: Vector2 = Vector2(parent.global_transform.origin.x, parent.global_transform.origin.z) + 10 * run_direction
	var done_moving: bool = state_machine.move_towards(target, stop_distance, run_acc)


func _on_RunTimer_timeout() -> void:
	if state_machine.state.name == "RunAway":
		state_machine.transition_deferred("Idle")
