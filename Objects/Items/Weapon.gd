tool
extends Spatial
class_name Weapon

enum TYPE {Sword, Axe, Spear}
export(TYPE) var type := TYPE.Sword setget set_type

func set_type(t):
	type = t
	for c in get_children():
		if c.name == str(TYPE.keys()[t]):
			c.visible = true
		else:
			c.visible = false
