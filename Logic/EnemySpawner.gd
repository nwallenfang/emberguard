extends Spatial

var player
var wagon
var ground_aabb

export var player_dist_min : float
export var player_dist_max : float

func _ready():
	player = Game.player
	#wagon = Game.wagon
	#gound_aabb = Game.ground_aabb

func is_point_suitable() -> bool:
	return false

func get_suitable_point() -> Vector3:
	return Vector3(0, 0, 0)

func spawn_one(enemy_name):
	pass
