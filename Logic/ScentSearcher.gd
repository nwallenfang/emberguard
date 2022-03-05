extends RayCast

var scent_emitter: ScentEmitter

func _ready():
	yield(get_tree().create_timer(.1), "timeout")
	scent_emitter = Game.player.scent_emitter

func get_target_position() -> Vector3:
	for scent in scent_emitter.scents:
		cast_to = scent
		if not is_colliding():
			return scent
	return global_transform.origin
