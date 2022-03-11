extends Spatial

var speed := 3.0

func _physics_process(delta):
	var dir = global_transform.origin.direction_to(Game.player.get_node("Head").global_transform.origin)
	global_transform.origin += dir * speed * delta


func _on_Lifetime_timeout():
	queue_free()


func _on_MagicHitbox_area_entered(area):
	queue_free()
