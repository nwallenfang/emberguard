extends AbstractState

export var target_distance: float = 5.0
export var stop_distance: float = 0.1
export var wandering_acceleration := 100.0

var target_position_xz:  Vector2

func _ready() -> void:
	state_machine = state_machine as EnemyStateMachine


func get_new_target(distance: float) -> Vector2:
	var random_angle = rand_range(0.0, 2*PI)
	return distance * Vector2.UP.rotated(random_angle)
	

func process(_delta: float, first_time_entering: bool):
	print("wandering")

	# for now stay wandering until you spot the player	
	# also check distance to player here and there and maybe deactivate yourself
	if first_time_entering:
		var xz_location = Vector2(parent.global_transform.origin.x, parent.global_transform.origin.z)
		target_position_xz = xz_location + get_new_target(target_distance)
		
	var done_moving: bool = state_machine.move_towards(target_position_xz, stop_distance, wandering_acceleration)
	
	if done_moving:
		state_machine.transition_deferred("Idle")
