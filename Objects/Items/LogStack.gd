extends Spatial

func make_flying():
	for c in get_children():
		c.make_flying()

func burn_effect():
	for c in get_children():
		c.burn_effect()

func update():
	yield(get_tree(), "idle_frame")
	for c in get_children():
		if c.name.begins_with("Log"):
			return
	queue_free()
