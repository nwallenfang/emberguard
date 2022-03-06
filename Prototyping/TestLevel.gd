extends Spatial

signal intro_button_pressed

func _ready() -> void:

	Game.player = $Player
	Game.wagon = $Wagon
	Game.ground_aabb = $Ground.get_transformed_aabb()
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
	
	yield(get_tree().create_timer(2.5), "timeout")
	
	$IntroCamera.move_to_transform($Pivot/Camera.global_transform)
	yield($IntroCamera/Tween, "tween_all_completed")
	Game.main_game_running = true
	$IntroCamera.current = false
	$Pivot/Camera.current = true

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			emit_signal("intro_button_pressed")
