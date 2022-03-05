extends Spatial
class_name Wagon

export(NodePath) var wagon_path
export var target_reach_distance := 1.0
var points: PoolVector3Array
var next_target: Vector3
var target_index: int setget set_target_index

func set_target_index(value):
	target_index = value
	next_target = points[target_index]

func _ready():
	wagon_path = get_node(wagon_path) as Path
	points = wagon_path.curve.get_baked_points()
	set_target_index(0)

func flat_direction_to(point: Vector3) -> Vector3:
	return Vector3(translation.x, 0, translation.z).direction_to(Vector3(point.x, 0, point.z))

func flat_distance_to(point: Vector3) -> float:
	return Vector2(translation.x, translation.z).distance_to(Vector2(point.x, point.z))

signal ending_reached

func _physics_process(delta):
	var dir = flat_direction_to(next_target)
#	var old = translation
	translation += dir * velocity * delta
	var dir2D = Vector2(dir.z, dir.x)
	rotation_degrees.y = rad2deg(dir2D.angle())
	if flat_distance_to(next_target) < target_reach_distance:
		if target_index + 1 == points.size():
			emit_signal("ending_reached")
		else:
			set_target_index(target_index + 1)

export(Curve) var speed_fire_curve: Curve
export var base_velocity = 2.4
var velocity = base_velocity
func set_fire_percent(value):
	$Fire.set_fire_percent(value)
	velocity = base_velocity * speed_fire_curve.interpolate(value)
	
