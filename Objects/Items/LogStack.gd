extends Spatial

func make_flying():
	for c in get_children():
		c.make_flying()

func burn_effect():
	for c in get_children():
		c.burn_effect()
