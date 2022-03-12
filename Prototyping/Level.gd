extends Spatial

signal intro_button_pressed

const ZOOM_SPEED = 0.5
onready var camera_to_player = $Player.global_transform.origin.direction_to($Pivot/Camera.global_transform.origin)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			# zoom in
			if event.button_index == BUTTON_WHEEL_UP:
				$Pivot/Camera.translate(-ZOOM_SPEED * camera_to_player)
			# zoom out
			if event.button_index == BUTTON_WHEEL_DOWN:
				$Pivot/Camera.translate(ZOOM_SPEED * camera_to_player)

func _ready() -> void:
	UI.get_node("BlackScreen").visible = true
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
	
	var start_transform = $IntroCamera.transform
	$IntroCamera.move_to_transform($Pivot/Camera.global_transform, 1)
	yield($IntroCamera, "camera_move_done")
	$IntroCamera.transform = start_transform
	UI.get_node("BlackScreen").visible = false
	
	# set the game to running after 2 secs
	# later this will be called once the intro cutscene is done
	yield(self, "intro_button_pressed")
	$MainTheme.play()
	UI.get_node("IntroPressAnyKey").visible = false
	set_process_input(false)
	
	# light fire with sound and wait a little
	Game.wagon.get_node("Fire/RefuelSound").play()
	Game.wagon.get_node("Fire").set_fire_percent(1.0)
	Game.wagon.get_node("Fire/Crackle").play()
	
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
	yield($IntroCamera, "camera_move_done")
#	$Player.god_mode = false
	$Wagon/Fire/FireParticles/Smoke.emitting = true
	Game.main_game_running = true
	$IntroCamera.current = false
	$Pivot/Camera.current = true
	$EnemySpawner.activate()
	$Wagon/WagonSound.play()
	$Wagon.slow_start()
	
	var _e = $Wagon.connect("ending_reached", self, "ending_cutscene", [], CONNECT_ONESHOT)

func ending_cutscene():
	# increase camera viewdistance 
	$Player.god_mode = true
	UI.get_node("FireHealthbar").visible = false
	UI.get_node("InteractLabel").visible = false
	UI.get_node("WagonMarker").visible = false
	$EnemySpawner.deactivate()
#	Game.main_game_running = false
	$Pivot/Camera.far = 300
	$Player/RemoteTransform.update_position = false
	$Pivot/Camera.move_to_transform($Ending/Camera.global_transform, 1.5)
	yield($Pivot/Camera, "camera_move_done")
	$Pivot/Camera.current = false
	$Ending/Camera.current = true
	$Ending/AnimationPlayer.play("camera")
	yield($Ending/AnimationPlayer, "animation_finished")
	$Tween.interpolate_property($MainTheme, "volume_db", null, -80, 5.2, Tween.EASE_IN)
	$Tween.interpolate_property($MainThemeFast, "volume_db", null, -80, 5.2, Tween.EASE_IN)
	$Tween.start()
	UI.get_node("TreasureIsSafe").visible = true
	yield(get_tree().create_timer(3.6), "timeout")
	UI.get_node("TreasureIsSafe").visible = false
	UI.game_end_won()
	

func _input(event):
	if event is InputEventKey or event is InputEventJoypadButton or event is InputEventMouseButton:
		if event.pressed:
			emit_signal("intro_button_pressed")


func _on_MainThemeFastStart_timeout() -> void:
	$MainThemeFast.play($MainTheme.get_playback_position())
