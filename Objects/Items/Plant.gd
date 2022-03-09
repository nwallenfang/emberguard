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
	Game.player.add_child(fireball)
	fireball.translate(Vector3(0.0, 2.8, 0.0))
	
	yield(get_tree().create_timer(3.0), "timeout")
	queue_free()
	


func make_flying():
	$InteractionObject.set_deferred("monitoring", false)
	$InteractionObject.set_deferred("monitorable", false)

func burn_effect():
	Game.fire_health += fire_value
