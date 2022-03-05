extends PhysicsMover3D
class_name WaterEnemy


signal player_detected  # not needed atm

func _ready() -> void:
	$EnemyStateMachine.enabled = true
	
	
func _process(delta: float) -> void:
	$EnemyStateMachine.process(delta)
	execute_movement(delta)
	
	



func _on_DetectionArea_body_entered(body: Node) -> void:
	if body is Player:
		emit_signal("player_detected")
		$EnemyStateMachine.transition_deferred("PlayerSpotted")
