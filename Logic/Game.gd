extends Spatial

const DEBUG_SKIP_INTRO = false  # TODO

var player: Player
var wagon: Wagon
var ground_aabb: AABB

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
	
	wagon.set_physics_process(running)
	main_game_running = running

func set_fire_health(new_health: float):
	fire_health = clamp(new_health, 0.0, 1.0)
	
	
	if fire_health <= 0.0:
		emit_signal("game_over")
		game_over()
	
	UI.set_fire_health(fire_health)
	get_tree().current_scene.get_node("Wagon").set_fire_percent(fire_health)
	
	
	
var fire_burn_speed := 0.005
func _process(delta: float) -> void:
	self.fire_health -= delta * fire_burn_speed
	player_distance_to_wagon = player.translation.distance_to(wagon.translation)

