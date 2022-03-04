extends Spatial

export var fire_value = 0.05

func interact():
	Game.player.hold_item("plant")
	queue_free()

func make_flying():
	$InteractionObject.set_deferred("monitoring", false)
	$InteractionObject.set_deferred("monitorable", false)

func burn_effect():
	Game.fire_health += fire_value
