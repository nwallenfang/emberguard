extends Spatial

signal intro_button_pressed

func _ready() -> void:

	Game.player = $Player
	Game.wagon = $Wagon
	Game.ground_aabb = $Ground.get_transformed_aabb()
	Game.ending = $Ending
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
	yield($IntroCamera/Tween, "tween_all_completed")
	Game.main_game_running = true
	$IntroCamera.current = false
	$Pivot/Camera.current = true
	
	$Wagon.connect("ending_reached", self, "ending_cutscene", [], CONNECT_ONESHOT)

func ending_cutscene():
	$Player/RemoteTransform.update_position = false
	$Pivot/Camera.move_to_transform($Ending/Camera.global_transform, 1.5)
	yield($Pivot/Camera/Tween, "tween_all_completed")
	print("reached")
	$Pivot/Camera.current = false
	$Ending/Camera.current = true
	$Ending/AnimationPlayer.play("camera")

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			emit_signal("intro_button_pressed")
