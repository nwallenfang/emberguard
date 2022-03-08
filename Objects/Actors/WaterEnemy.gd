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
		
func _physics_process(delta: float) -> void:
	if physics_movement_enabled:
		execute_movement(delta)
		
func _on_DetectionArea_area_entered(_area: Area) -> void:
	if $EnemyStateMachine.state.name == "Wandering": # or idle in theory
		emit_signal("player_detected")
		$EnemyStateMachine.transition_deferred("PlayerSpotted")

export var health := 3
var knockback_power := 900.0
func _on_Hurtbox_area_entered(area):
	var direction = area.global_transform.origin.direction_to(global_transform.origin)
	if area.name.begins_with("Player"):
		health -= 1
		direction.y = 0
		direction = direction.normalized() * knockback_power
		direction.y = knockback_power * .6
		$HitParticles.emitting = true
		$HitParticles.restart()
	else:
		direction.y = 0
		direction = direction.normalized() * knockback_power * .1
		direction.y = knockback_power * .8
	velocity = Vector3.ZERO
	add_acceleration(direction)
	$Hurtbox.set_deferred("monitoring", false)
	$Hurtbox.set_deferred("monitorable", false)
	$InvincTimer.start()
	#yield(get_tree().create_timer(.5), "timeout")
	if health == 0:
		$EnemyStateMachine.transition_deferred("Dying")

func _on_InvincTimer_timeout():
	$Hurtbox.set_deferred("monitoring", true)
	$Hurtbox.set_deferred("monitorable", true)
