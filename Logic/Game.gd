extends Spatial

const DEBUG_SKIP_INTRO = false  # TODO

var main_cam: Camera
var player: Player
var wagon: Wagon
var ending
var ground_aabb: AABB
var enemy_spawner
var moon : DirectionalLight

var player_distance_to_wagon := 0.0

var fire_health := 1.0 setget set_fire_health

var main_game_running: bool = true setget set_main_game_running

signal game_over
signal main_game_started

func reset():
	fire_health = 1.0

func game_over():
	get_tree().paused = true
	# TODO
	# mayyybe we will play some animation of the treasure being stolen
	# show some button to trigger restart

func set_main_game_running(running: bool):
	if not main_game_running and running:
		emit_signal("main_game_started")
	if not running:
		wagon.set_fire_percent(0.0)
		
	set_process(running)
	
	player.set_physics_process(running)
	wagon.set_physics_process(running)
	main_game_running = running

func set_fire_health(new_health: float):
	fire_health = clamp(new_health, 0.0, 1.0)

	if fire_health <= 0.0 and not wagon.get_node("Fire").fuel_flying:
		player.CONTROLS_ENABLED = false
		enemy_spawner.deactivate()
		#moon.light_energy = 1.2
		Game.get_node("MainTheme").stop()
		Game.get_node("MainThemeFast").stop()
		wagon.game_over()
		yield(get_tree(), "idle_frame")
		player.visible = false
		UI.get_node("FireHealthbar").visible = false
		yield(wagon, "game_over_animation_finished")
		main_game_running = false
		emit_signal("game_over")
		game_over()
	
	UI.set_fire_health(fire_health)
	get_tree().current_scene.get_node("Wagon").set_fire_percent(fire_health)

var cutscene := false
var minions_activated := false

var fire_burn_speed := 0.014
func _process(delta: float) -> void:
	if not cutscene:
		self.fire_health -= delta * fire_burn_speed
		player_distance_to_wagon = player.translation.distance_to(wagon.translation)
	else:
		self.fire_health = fire_health

