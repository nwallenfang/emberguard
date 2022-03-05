extends Spatial
class_name ScentEmitter

export var scent_count := 50

var scents := []

func add_scent():
	var pos = global_transform.origin
	scents.insert(0, pos)
	if scents.size() > scent_count:
		scents.remove(scent_count)

func _on_Timer_timeout():
	add_scent()
