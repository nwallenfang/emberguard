extends Spatial

export var beam_shoot := 0.0 setget set_beam_shoot

func _ready():
	visible = false

func set_beam_shoot(x):
	if is_instance_valid($Laser/MeshInstance):
		beam_shoot = x
		$Laser/MeshInstance.material_override.set("shader_param/shoot_offset", x)

func start_cutscene():
	visible = true
	Game.main_cam.current=true
	Game.cutscene = true
	$TriggerTimer.stop()
	$AnimationPlayer.play("cutscene")
	Game.enemy_spawner.deactivate()

func cut_scene_wagon_hit():
	var force_field = Game.wagon.get_node("MagicForceField")
	force_field.visible = true
	$Tween.interpolate_property(force_field.get("material/0"), "shader_param/active", 0.0, 1.0, 2)
	$Tween.interpolate_property(Game.wagon, "velocity_scale", 1.0, 0.0, 1.0)
	$Tween.start()
	$MagicEnemy.visible = true

func cutscene_done():
	Game.cutscene = false
	Game.enemy_spawner.activate()
	Game.main_cam.current = true
	Game.minions_activated = true

export var trigger_distance := 36.0
func _on_TriggerTimer_timeout():
	var distance = global_transform.origin.distance_to(Game.wagon.global_transform.origin)
	if distance <= trigger_distance and not Game.cutscene:
		start_cutscene()

func master_defeated():
	pass

func _physics_process(delta):
	if Input.is_action_just_pressed("speed_cheat_on"):
		#$Camera.current = true
		Game.wagon.velocity_scale = 15.0
	if Input.is_action_just_pressed("speed_cheat_off"):
		#$Camera.current = false
		Game.wagon.velocity_scale = 1.0
