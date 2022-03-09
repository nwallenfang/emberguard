extends Spatial

export var damage = 3
export var stop_distance = 0.05
export var fly_velocity = 0.3

enum State {
	Idle,
	Attacking,
	Destroyed
}

var state = State.Idle

func _ready() -> void:
	$EnemyDetectArea.connect("area_entered", self, "_on_EnemyDetectArea_area_entered", [], CONNECT_ONESHOT)

var enemy: Node  # not WaterEnemy since there will be others too later
func state_attacking(delta: float):
	var done = move_towards(enemy.global_transform.origin, stop_distance, fly_velocity)
	if done:
		enemy.get_node("EnemyStateMachine").transition_deferred("Dying")
		state = State.Destroyed

func _physics_process(delta: float) -> void:
	match state:
		State.Idle:
			pass
		State.Attacking:
			state_attacking(delta)
		State.Destroyed:
			# play particles, apply damage
			queue_free()


func _on_EnemyDetectArea_area_entered(enemy_hurtbox: Area) -> void:
	enemy = enemy_hurtbox.get_parent()
	state = State.Attacking
	set_as_toplevel(true)  # from now on move independent from player
	
	
func move_towards(target: Vector3, stop_distance: float, vel: float) -> bool:
	# returns whether the movement is completed as a boolean
	var distance: float = global_transform.origin.distance_to(target)
	
	if distance < stop_distance:
		return true
	else:
		var direction: Vector3 = global_transform.origin.direction_to(target)
		self.global_transform.origin += vel * direction.normalized()
		
		return false
