extends Spatial

export var fire_value = 0.05

func interact():
	Game.player.hold_item("plant")
	queue_free()

func burn_effect():
	Game.fire_health += fire_value
