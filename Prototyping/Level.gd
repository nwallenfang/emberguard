extends Spatial

signal intro_button_pressed

func _ready() -> void:
#	$Player.god_mode = true  # uncomment when pushing to production
	$WorldEnvironment.environment.fog_enabled = true
	Game.player = $Player
	$Player.connect("too_much_to_carry", UI, "trigger_too_much_to_carry")
	$Player.connect("cannot_attack", UI, "trigger_cannot_attack")
	Game.wagon = $Wagon
	Game.wagon.get_node("Chest").open_percent = .8
	Game.ground_aabb = $Ground.get_transformed_aabb()
	Game.ending = $Ending
	Game.enemy_spawner = $EnemySpawner
	Game.moon = $Moon
	$Pivot/Listener.make_current()
	$IntroCamera.current = true
	Game.main_game_running = false
	
	# set the game to running after 2 secs
	# later this will be called once the intro cutscene is done
	yield(self, "intro_button_pressed")
	UI.get_node("IntroPressAnyKey").visible = false
	set_process_input(false)
	
	# light fire with sound and wait a little
	Game.wagon.get_node("Fire/RefuelSound").play()
	Game.wagon.get_node("Fire").set_fire_percent(1.0)
	
	# have treasure slowly close and stop treasure particles
	$Tween.interpolate_property(Game.wagon.get_node("Chest"), "open_percent", 0.8, 0.0, 2.0)
	$Tween.start()
	
	yield($Tween, "tween_all_completed")
	
	Game.wagon.get_node("Chest/TreasureSimulation").emitting = false
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	$IntroCamera.move_to_transform($Pivot/Camera.global_transform)
	yield(get_tree().create_timer(0.5), "timeout")
	$WaterEnemy.queue_free()
	$WaterEnemy2.queue_free()
	yield($IntroCamera/Tween, "tween_all_completed")
#	$Player.god_mode = false
	$Wagon/Fire/FireParticles/Smoke.emitting = true
	Game.main_game_running = true
	$IntroCamera.current = false
	$Pivot/Camera.current = true
	$EnemySpawner.activate()
	#$EnemySpawner.all_enemies["water"].append_array([$WaterEnemy, $WaterEnemy2])
	
	var _e = $Wagon.connect("ending_reached", self, "ending_cutscene", [], CONNECT_ONESHOT)

func ending_cutscene():
	# increase camera viewdistance 
	$Pivot/Camera.far = 300
	$Player/RemoteTransform.update_position = false
	$Pivot/Camera.move_to_transform($Ending/Camera.global_transform, 1.5)
	yield($Pivot/Camera/Tween, "tween_all_completed")
	$Pivot/Camera.current = false
	$Ending/Camera.current = true
	$Ending/AnimationPlayer.play("camera")
	yield(get_tree().create_timer(3.0), "timeout")
	UI.game_end_won()
	

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			emit_signal("intro_button_pressed")
