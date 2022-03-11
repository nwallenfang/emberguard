extends Spatial

export var fire_value = 0.225

func interact():
	var success = Game.player.try_hold_item("log")
	if success:
		queue_free()

func make_flying():
	$InteractionObject.set_deferred("monitoring", false)
	$InteractionObject.set_deferred("monitorable", false)
	#$StaticBody/CollisionShape.set_deferred("disabled", true)

func burn_effect():
	Game.fire_health += fire_value
