extends Spatial

func interact():
	Game.player.hold_item("plant")
	queue_free()
