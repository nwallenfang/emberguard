extends Spatial

var player: Player
var wagon: Wagon
var ground_aabb: AABB

export var player_dist_min : float = 10
export var player_dist_max : float = 20
export var despawn_range : float = 40
export var wagon_distance: float = 4

var all_enemies := {}
var enemy_target_count : Dictionary = {}
var enemy_types = ["water"]

export var water_target_count := 8

var active = true

func deactivate():
	active = false
	for e in all_enemies["water"]:
		e.queue_free()
	all_enemies["water"].clear()

func _ready():
	yield(get_tree().create_timer(.1),"timeout")
	player = Game.player
	wagon = Game.wagon
	ground_aabb = Game.ground_aabb
	ground_aabb = ground_aabb.expand(Vector3(0, -4, 0))
	ground_aabb = ground_aabb.expand(Vector3(0, 4, 0))
	
	player_dist_max = max(player_dist_max, player_dist_min)
	
	for enemy_type in enemy_types:
		all_enemies[enemy_type] = []
	enemy_target_count["water"] = water_target_count

func is_point_suitable(p: Vector3) -> bool:
	if not ground_aabb.encloses(AABB(p, Vector3(.5,.5,.5))):
		return false
	if wagon.translation.distance_to(p) < wagon_distance:
		return false
	return true

func get_random_point_around_player() -> Vector3:
	var rand_radians = randf() * PI * 2
	var _range = player_dist_max - player_dist_min
	var rand_distance = sqrt(randf()) * _range + player_dist_min
	return Vector3(rand_distance, 0, 0).rotated(Vector3.UP, rand_radians)

func get_suitable_point():
	for _i in range(40):
		var p = get_random_point_around_player()
		if is_point_suitable(p):
			return p
	return null

const WATER = preload("res://Objects/Actors/WaterEnemy.tscn")

func try_spawn_one(enemy_name) -> bool:
	var p = get_suitable_point()
	if p == null:
		print("fail")
		return false
	var inst
	match(enemy_name):
		"water":
			inst = WATER.instance()
	get_tree().current_scene.add_child(inst)
	inst.translation = p + player.translation
	all_enemies[enemy_name].append(inst)
	#print("spawned enemy at" + str(p))
	return true


func _on_Timer_timeout():
	if not active:
		return
	for enemy_type in enemy_types:
		var delete_enemies = []
		for enemy in all_enemies[enemy_type]:
			if not is_instance_valid(enemy):
				delete_enemies.append(enemy)
				continue
			if enemy.translation.distance_to(player.translation) > despawn_range:
				delete_enemies.append(enemy)
		for enemy in delete_enemies:
			all_enemies[enemy_type].erase(enemy)
			if is_instance_valid(enemy):
				enemy.queue_free()
		
		if all_enemies[enemy_type].size() < enemy_target_count[enemy_type]:
			#print("try spawning enemy")
			var _err = try_spawn_one(enemy_type)
