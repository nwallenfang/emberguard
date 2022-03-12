extends Spatial
class_name Wagon

export(NodePath) var wagon_path
export var target_reach_distance := 1.0
var points: PoolVector3Array
var next_target: Vector3
var target_index: int setget set_target_index

# has the speed value for the wheels
onready var wheels_anim_player: AnimationPlayer = $WagonModel/AnimationPlayer

func set_target_index(value):
	target_index = value
	next_target = points[target_index]

func _ready():
	wagon_path = get_node(wagon_path) as Path
	points = wagon_path.curve.get_baked_points()
	set_target_index(0)
	$GameOver.visible = false

func flat_direction_to(point: Vector3) -> Vector3:
	return Vector3(translation.x, 0, translation.z).direction_to(Vector3(point.x, 0, point.z))

func flat_distance_to(point: Vector3) -> float:
	return Vector2(translation.x, translation.z).distance_to(Vector2(point.x, point.z))


func get_future_angle(future):
	var future_index = min(target_index + future, points.size() - 1)
	var dir = flat_direction_to(points[future_index])
	var dir2D = Vector2(dir.z, dir.x)
	return dir2D.angle()

func get_radian_direction_and_distance(from, to):
	var direction = 1
	var distance = 2*PI
	for _to in [to - 2*PI, to, to + 2*PI]:
		if abs(_to - from) < distance:
			distance = abs(_to - from)
			direction = sign(_to - from)
	return [direction, distance]

export var turn_speed := PI / 2
export var turn_future_offset := 10

signal ending_reached
export var ending_distance := 2.0


func _physics_process(delta):
	var dir = flat_direction_to(next_target)
#	var old = translation
	translation += dir * velocity * delta
#	var dir2D = Vector2(dir.z, dir.x)
	
	
	#rotation_degrees.y = rad2deg(dir2D.angle())
	var dir_and_dist = get_radian_direction_and_distance(deg2rad(rotation_degrees.y), get_future_angle(turn_future_offset))
	var rotation_offset = dir_and_dist[0] * max(delta * turn_speed, dir_and_dist[1])
	#if dir_and_dist[1] < 
	rotation_degrees.y +=  rotation_offset
	
	if flat_distance_to(next_target) < target_reach_distance:
		if translation.distance_to(Game.ending.translation) < ending_distance:
			emit_signal("ending_reached")
		if target_index + 1 == points.size():
			pass
		else:
			set_target_index(target_index + 1)

export(Curve) var speed_fire_curve: Curve
export var base_velocity = 2.4
export var wheels_base_speed = 0.35
var velocity = base_velocity
var velocity_scale := 0.0
func set_fire_percent(value):
	$Fire.set_fire_percent(value)
	velocity = velocity_scale * base_velocity * speed_fire_curve.interpolate(value)
	wheels_anim_player.playback_speed = velocity_scale * wheels_base_speed * speed_fire_curve.interpolate(value)
	
#	if velocity > 0.01 and $DustTrack.emitting == false:
#		$DustTrack.emitting = true
#		$DustTrack2.emitting = true
#	if velocity <= 0.01:
#		$DustTrack.emitting = false
#		$DustTrack2.emitting = false

func slow_start():
	$SpeedTurnUp.interpolate_property(self, "velocity_scale", 0.0, 1.0, 20)
	$SpeedTurnUp.interpolate_property($DustTrack.process_material, "shader_param/scale", 0.0, 2.8, 20,Tween.TRANS_CUBIC, Tween.EASE_IN)
	$SpeedTurnUp.start()
	$DustTrack.emitting = false
	$DustTrack2.emitting = false
	yield(get_tree().create_timer(10), "timeout")
	$DustTrack.emitting = true
	$DustTrack2.emitting = true

signal game_over_animation_finished

func game_over():
	$GameOver/Cam1/Listener.make_current()
	$Fire/Crackle.unit_db = -2.0
	$GameOver/FireSoundTween.interpolate_property($Fire/Crackle, "unit_db", -2.0, -15.0, 2)
	$GameOver/FireSoundTween.start()
	$WagonSound.playing = false
	$DustTrack.emitting = false
	$DustTrack2.emitting = false
	$GameOver.visible = true
	$Fire/FireParticles/Smoke.emitting = false
	$GameOver/AnimationPlayer.play("GameOver")
	yield($GameOver/AnimationPlayer,"animation_finished")
	emit_signal("game_over_animation_finished")
