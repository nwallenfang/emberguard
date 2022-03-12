extends AbstractState

export var target_distance: float = 5.0
export var target_distance_random: float = 2.0
export var stop_distance: float = 0.2
export var wandering_acceleration := 30.0

var target_position_xz:  Vector2

func _ready() -> void:
	state_machine = state_machine as EnemyStateMachine


func get_new_target(origin: Vector2, distance: float, distance_random: float = 4.0) -> Vector2:
	distance += (randf() - .5) * 2.0 * distance_random
	var random_angle = rand_range(0.0, 2*PI)
	return origin + distance * Vector2.UP.rotated(random_angle)
	
#func player_detected():
#	pass

func process(_delta: float, first_time_entering: bool):
	# for now stay wandering until you spot the player	
	# also check distance to player here and there and maybe deactivate yourself
	if first_time_entering:
		var xz_location = Vector2(parent.global_transform.origin.x, parent.global_transform.origin.z)
		var target_location = xz_location
		for i in range(20):
			var new_target = get_new_target(xz_location, target_distance, target_distance_random)
			if not Game.main_game_running:
				var wagon_location = Vector2(Game.wagon.global_transform.origin.x, Game.wagon.global_transform.origin.z)
				new_target = get_new_target(wagon_location, 4.9, 2.1)
			if parent.get_node("ScentSearcher").test_position_xz(new_target):
				target_location = new_target
				break
		target_position_xz = target_location
	
	if parent.get_node("DetectionArea").monitoring and not parent.get_node("DetectionArea").get_overlapping_areas().empty():
		parent.get_node("DetectionArea").set_deferred("monitoring", false)
		yield(get_tree(), "idle_frame")
		parent.get_node("DetectionArea").set_deferred("monitoring", true)
		
	var done_moving: bool = state_machine.move_towards(target_position_xz, stop_distance, wandering_acceleration if Game.main_game_running else 22.0)
	
	if done_moving and get_parent().state.name == "Wandering":
		state_machine.transition_deferred("Idle")
