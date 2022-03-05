extends StateMachine

class_name EnemyStateMachine

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func process(delta: float) -> void:
	if not enabled:
		return
	var this_was_the_first_time = first_time_entering
	state.process(delta, first_time_entering)
	if this_was_the_first_time:
		# first_time_entering is set again in transition method
		first_time_entering = false


func set_enabled(senabled: bool):
	enabled = senabled
	
	
func move_towards(target: Vector2, stop_distance: float, acc: float) -> bool:
	# returns whether the movement is completed as a boolean
	var distance: float = Vector2(global_transform.origin.x, global_transform.origin.z).distance_to(target)
	
	if distance < stop_distance:
		return true
	else:
		var direction: Vector2 = Vector2(global_transform.origin.x, global_transform.origin.z).direction_to(target)
		get_parent().add_plane_acceleration(acc * direction.normalized())
		return false
