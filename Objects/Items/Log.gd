extends Spatial

export var fire_value = 0.225

func interact():
	var success = Game.player.try_hold_item("log")
	if success:
		queue_free()
		if get_parent().name.begins_with("LogStack"):
			get_parent().update()

func make_flying():
	$InteractionObject.set_deferred("monitoring", false)
	$InteractionObject.set_deferred("monitorable", false)
	#$StaticBody/CollisionShape.set_deferred("disabled", true)

func burn_effect():
	Game.fire_health += fire_value
