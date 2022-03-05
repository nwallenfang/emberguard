extends PhysicsMover3D
class_name WaterEnemy


signal player_detected  # not needed atm

var physics_movement_enabled = true

func _ready() -> void:
	$EnemyStateMachine.enabled = true
	
	
func _process(delta: float) -> void:
	$EnemyStateMachine.process(delta)
	var look_direction := -Vector3(acceleration)
	var look_vec2 := Vector2(acceleration.x, acceleration.z)
	
	var angular_velocity := 30.0
	if look_vec2 != Vector2.ZERO:
		rotation.y = lerp_angle(rotation.y, atan2(-look_direction.x, -look_direction.z), angular_velocity * delta)
		
	if physics_movement_enabled:
		execute_movement(delta)


func _on_DetectionArea_area_entered(_area: Area) -> void:
	if $EnemyStateMachine.state.name == "Wandering": # or idle in theory
		emit_signal("player_detected")
		$EnemyStateMachine.transition_deferred("PlayerSpotted")
