extends Spatial

var speed := 6.0
var exploding := false

func _physics_process(delta):
	if not exploding:
		var dir = global_transform.origin.direction_to(Game.player.get_node("Head").global_transform.origin)
		global_transform.origin += dir * speed * delta
	if global_transform.origin.distance_to(Game.player.get_node("Head").global_transform.origin) <.1:
		explode()

func _on_Lifetime_timeout():
	explode()

func _on_MagicHitbox_area_entered(_area):
	explode()

func explode():
	if not exploding:
		exploding = true
		for m in [$MeshInstance, $MeshInstance2, $MeshInstance3]:
			m.visible = false
		$MagicHitbox.set_deferred("monitorable", false)
		$Explosion.emitting = true
		$ExplodeSound.play()
		yield(get_tree().create_timer(2.1), "timeout")
		queue_free()

func _on_CollosionDetection_body_entered(body):
	if not body is Player:
		explode()
