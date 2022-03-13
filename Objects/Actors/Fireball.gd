extends Spatial

class_name Fireball

export var stop_distance = 0.10
export var fly_velocity = 0.3

enum State {
	Idle,
	Attacking,
	Destroyed
}

var state = State.Idle

signal shoot_fireball

func _ready() -> void:
	$EnemyDetectArea.translation += Vector3(0, 20, 0)
	yield(get_tree().create_timer(1.7), "timeout")
	$EnemyDetectArea.connect("area_entered", self, "_on_EnemyDetectArea_area_entered", [], CONNECT_ONESHOT)
	$EnemyDetectArea.translation -= Vector3(0, 20, 0)

var enemy: Node  # not WaterEnemy since there will be others too later
func state_attacking(_delta: float):
	if not is_instance_valid(enemy):
		state = State.Destroyed
		return
		
	var done = move_towards(enemy.global_transform.origin, stop_distance, fly_velocity)
	if done:
		enemy.get_node("EnemyStateMachine").transition_deferred("Dying")
		state = State.Destroyed

func update_hover_offset():
	hover_time_offset = float(OS.get_ticks_msec()) * .001 + hover_xscale * translation.x

var hover_time_offset : float
var hover_xscale := 4.5
var hover_time_scale := .8
var hover_height := .3
var hover_offset := .0
func _physics_process(delta: float) -> void:
	hover_time_offset += delta
	$Mesh.translation.y = hover_offset + hover_height * sin(hover_time_offset * hover_time_scale)
	match state:
		State.Idle:
			pass
		State.Attacking:
			state_attacking(delta)
		State.Destroyed:
			emit_signal("shoot_fireball")
			# play particles, apply damage
			queue_free()

func activate():
	yield(get_tree().create_timer(1.2), "timeout")
	$EnemyDetectArea.set_deferred("monitoring", true)

func _on_EnemyDetectArea_area_entered(enemy_hurtbox: Area) -> void:
	enemy = enemy_hurtbox.get_parent()
	if enemy.name != "MagicMaster":
		state = State.Attacking
		set_as_toplevel(true)  # from now on move independent from player
	else:
		$EnemyDetectArea.connect("area_entered", self, "_on_EnemyDetectArea_area_entered", [], CONNECT_ONESHOT)

func move_towards(target: Vector3, stop_distance: float, vel: float) -> bool:
	# returns whether the movement is completed as a boolean
	var distance: float = global_transform.origin.distance_to(target)
	
	if distance < stop_distance:
		return true
	else:
		var direction: Vector3 = global_transform.origin.direction_to(target)
		self.global_transform.origin += vel * direction.normalized()
		
		return false
