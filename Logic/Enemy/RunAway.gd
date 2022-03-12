extends AbstractState

export var stop_distance: float = 0
export var run_acc := 60.0

var run_direction:  Vector2

func process(_delta: float, first_time_entering: bool):
	if first_time_entering:
		if $RunTimer.is_stopped():
			$RunTimer.start(2.0 if Game.main_game_running else 5.0)
	var target: Vector2 = Vector2(parent.global_transform.origin.x, parent.global_transform.origin.z) + 10 * run_direction
	var done_moving: bool = state_machine.move_towards(target, stop_distance, run_acc)


func _on_RunTimer_timeout() -> void:
	state_machine.transition_deferred("Idle")
