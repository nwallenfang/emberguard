extends Spatial

var alpha := 1.0 setget set_alpha

func set_alpha(a):
	alpha = a
	$Spatial/Visual.material_override.set("shader_param/albedo:a", a)
	$Spatial/Visual2.material_override.set("shader_param/albedo:a", a)

func set_hitbox(b):
	$HitboxBlast.set_deferred("monitorable", b)
	$HitboxBlast.set_deferred("monitoring", b)
