extends RayCast

var scent_emitter: ScentEmitter

func _ready():
	yield(get_tree().create_timer(.1), "timeout")
	scent_emitter = Game.player.scent_emitter

func get_target_position() -> Vector3:
	if not is_instance_valid(scent_emitter):
		scent_emitter = Game.player.scent_emitter
	for scent in scent_emitter.scents:
		print(scent)
		cast_to = to_local(scent)
		force_raycast_update()
		if not is_colliding():
			return scent
	return global_transform.origin

func test_position_xz(pos: Vector2) -> bool:
	var pos3D = Vector3(pos.x, global_transform.origin.y, pos.y)
	cast_to = to_local(pos3D)
	force_raycast_update()
	return not is_colliding()
