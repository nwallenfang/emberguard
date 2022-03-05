extends PhysicsMover3D
class_name WaterEnemy

func _ready() -> void:
	$EnemyStateMachine.enabled = true
	
	
func _process(delta: float) -> void:
	$EnemyStateMachine.process(delta)
	execute_movement(delta)
	
	

