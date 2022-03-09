extends Spatial

export var fire_value = 0.05

const FIREBALL = preload("res://Objects/Actors/Fireball.tscn")
func interact():
	# consume plant immediately (don't pick it up)
#	var success = Game.player.try_hold_item("plant")
#	if success:
	$Sparks.emitting = true
	$Lotus.visible = false
	var fireball = FIREBALL.instance()
	# see how many fireballs already exist in the player
	var existing_fireballs: Array = get_tree().get_nodes_in_group("Fireball")

	var x_translation = 0.2 * existing_fireballs.size()
	if existing_fireballs.size() == 0:
		# are set to false in beginning, so multiple balls dont shoot the same target
		fireball.get_node("EnemyDetectArea").set_deferred("monitoring", true)
	else:
		existing_fireballs[existing_fireballs.size()-1].connect("shoot_fireball", fireball, "activate")
	# if there is already a fireball connect to that fireball's signal
	# once that fireball has fired, this one can be activated
	
	Game.player.add_child(fireball)
	fireball.translate(Vector3(x_translation, 2.8, 0.0))
	
	yield(get_tree().create_timer(3.0), "timeout")
	queue_free()
	


func make_flying():
	$InteractionObject.set_deferred("monitoring", false)
	$InteractionObject.set_deferred("monitorable", false)

func burn_effect():
	Game.fire_health += fire_value
