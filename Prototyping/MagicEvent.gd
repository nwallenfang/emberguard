extends Spatial

export var beam_shoot := 0.0 setget set_beam_shoot

func set_beam_shoot(x):
	beam_shoot = x
#	$Laser/MeshInstance.material_override.set("shader_param/shoot_offset", x)

func start_cutscene():
	pass

func cut_scene_wagon_hit():
	pass

func cutscene_done():
	pass
