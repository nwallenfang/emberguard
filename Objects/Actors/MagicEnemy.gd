extends PhysicsMover3D
class_name MagicEnemy


signal player_detected  # not needed atm

var physics_movement_enabled = true

func _ready() -> void:
	$EnemyStateMachine.enabled = true
	bounce_time = randf() * 1000.0

export var minion := false

var bounce_time : float
var bounce_time_scale := 6.5
var last_frame_sinus := 0.0
var bounce_override_factor := 0.0
var bounce_override := 0.0
func _physics_process(delta: float) -> void:
	bounce_time += delta
	var scaled_bouce_time := bounce_time * bounce_time_scale
	var sinus = sin(scaled_bouce_time)
	sinus = lerp(sinus, bounce_override, bounce_override_factor)
	set_bouce_scale(sinus * .2)
	set_bouce_height(sinus * .75)
	FRICTION = .85 + min(sinus * .4, 0.0)
	if $EnemyStateMachine.state.name == "Attacking":
		FRICTION = .85
	if not $BoingSound.playing:
		if sinus > -.1 and sinus < .0:
			if last_frame_sinus < sinus:
				$BoingSound.play()
	last_frame_sinus = sinus
	
	$EnemyStateMachine.process(delta)
	#print($EnemyStateMachine.state.name)
	
	var look_direction = -Vector3(acceleration)
	var look_vec2 := Vector2(acceleration.x, acceleration.z)
	
	var angular_velocity := 30.0
	if look_vec2 != Vector2.ZERO and velocity.length() > .1:
		rotation.y = lerp_angle(rotation.y, atan2(-look_direction.x, -look_direction.z), angular_velocity * delta)
	
	if physics_movement_enabled:
		execute_movement(delta)
		
func _on_DetectionArea_area_entered(_area: Area) -> void:
	#print("detect")
	if minion and not Game.minions_activated:
		return
	if not Game.main_game_running:
		return
	if $EnemyStateMachine.state.name == "Wandering" or $EnemyStateMachine.state.name == "Idle": # or idle in theory
		emit_signal("player_detected")
		$EnemyStateMachine.transition_deferred("PlayerSpotted")

export var health := 3
var knockback_power := 900.0
func _on_Hurtbox_area_entered(area):
	if area.name.begins_with("EnemyDetect"):
		return
	if area.name.begins_with("Scare"):
		if minion:
			return
		if area.get_parent().fire_percent <= .03:
			return
	var direction = area.global_transform.origin.direction_to(global_transform.origin)
	if area.name.begins_with("Player"):
		health -= 1
		direction.y = 0
		direction = direction.normalized() * knockback_power
		direction.y = knockback_power * .6
		$GettingHitSound.play()
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


func _on_DyingTimer_timeout() -> void:
	pass # Replace with function body.


func set_bouce_scale(x: float):
	$magician.scale = Vector3(1.0 - x, 1.0 + x, 1.0 - x)

func set_bouce_height(x: float):
	$magician.translation.y = max(.0, x)
