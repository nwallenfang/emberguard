extends Spatial

func interact():
	Game.player.hold_item("log")
	queue_free()
