extends AbstractState

export var abort_distance := 8.0

func bounce_animation():
	parent.bounce_override = 0.0
	$BouceAnimationTween.interpolate_property(parent, "bounce_override_factor", 0.0, 1.0, 1.0)
	$BouceAnimationTween.start()

func process(_delta: float, first_time_entering: bool):
	if first_time_entering:
		bounce_animation()
		$Timer.start()
		_on_Timer_timeout()
	if get_parent().state.name != "MagicAttack":
		quit_attacking()
		return
	var player_xz = Vector2(Game.player.global_transform.origin.x, Game.player.global_transform.origin.z)
	var parent_xz = Vector2(parent.global_transform.origin.x, parent.global_transform.origin.z)
	parent.rotation_degrees.y = parent_xz.angle_to(player_xz)

const MAGIC_BALL = preload("res://Objects/Actors/MagicBall.tscn")

func quit_attacking():
	$BouceAnimationTween.interpolate_property(parent, "bounce_override_factor", 1.0, 0.0, .6)
	$BouceAnimationTween.start()
	$Timer.stop()
	state_machine.transition_deferred("Idle")

func _on_Timer_timeout():
	if get_parent().state.name != "MagicAttack" or parent.global_transform.origin.distance_to(Game.player.global_transform.origin) > abort_distance:
		quit_attacking()
		return
	var ball = MAGIC_BALL.instance()
	get_tree().current_scene.add_child(ball)
	ball.global_transform.origin = parent.global_transform.origin + Vector3(0, 1, 0)
