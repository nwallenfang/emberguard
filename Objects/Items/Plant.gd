extends Spatial

export var fire_value = 0.05

const FIREBALL = preload("res://Objects/Actors/Fireball.tscn")
func interact():
	# consume plant immediately (don't pick it up)
#	var success = Game.player.try_hold_item("plant")
#	if success:
	$Sparks.emitting = true
	$Lotus.visible = false
	$InteractionObject.set_deferred("monitoring", false)
	$InteractionObject.set_deferred("monitorable", false)
	
	create_fireball()
	yield(get_tree().create_timer(.4), "timeout")
	create_fireball()
	yield(get_tree().create_timer(.4), "timeout")
	create_fireball()
	yield(get_tree().create_timer(2), "timeout")
	queue_free()

func create_fireball():
	$AudioStreamPlayer.play()
	var fireball = FIREBALL.instance()
		# see how many fireballs already exist in the player
	var existing_fireballs: Array = get_tree().get_nodes_in_group("Fireball")

	var x_translation = 0.35 * ((existing_fireballs.size() + 1) / 2) * ((existing_fireballs.size() % 2) * 2 - 1)
	if existing_fireballs.size() == 0:
		# are set to false in beginning, so multiple balls dont shoot the same target
		fireball.get_node("EnemyDetectArea").set_deferred("monitoring", true)
	else:
		var pre_ball = existing_fireballs[existing_fireballs.size()-1]
		fireball.get_node("EnemyDetectArea").set_deferred("monitoring", true)
		pre_ball.get_node("EnemyDetectArea").set_deferred("monitoring", false)
		fireball.connect("shoot_fireball", pre_ball, "activate")
	# if there is already a fireball connect to that fireball's signal
	# once that fireball has fired, this one can be activated
	$OmniLight.visible = false
	Game.player.add_child(fireball)
	fireball.translate(Vector3(x_translation, 3.0, 0.0))
	fireball.update_hover_offset()

func make_flying():
	$InteractionObject.set_deferred("monitoring", false)
	$InteractionObject.set_deferred("monitorable", false)

func burn_effect():
	Game.fire_health += fire_value
