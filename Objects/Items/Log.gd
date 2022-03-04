extends Spatial

export var fire_value = 0.15

func interact():
	Game.player.hold_item("log")
	queue_free()
	
func burn_effect():
	Game.fire_health += fire_value
