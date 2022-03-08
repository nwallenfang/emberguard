extends Spatial

export var fire_percent : float = 0.0 setget set_fire_percent
export(Curve) var throw_curve: Curve
export(Texture) var brightness_noise
export(Curve) var flicker_curve: Curve

# omnilight flickering variables
export var min_energy = 1

export var flicker_chance = 0.15  # chance per second to trigger flicker (should be independent from frame-rate)
export var flicker_length = 200 # in ms
export var natural_variation = 0.1
var time: float = 0.0
var currently_flickering := false
var flicker_start_time
var flicker_intensity

var omnilight_base = 0.0

func _ready():
	set_fire_percent(fire_percent)

func set_fire_percent(value):
	fire_percent = value
	$Placeholder.scale.y = value
	$Placeholder.translation.y = .4 * value
	$FireParticles.set_fire_percent(value)
	
	if not currently_flickering:
		omnilight_base = value

func interact():
	if Game.player.item_holded_count > 0:
		var item = Game.player.make_item() as Spatial
		item.make_flying()
		Game.player.loose_item()
		item.global_transform.origin = Game.player.global_transform.origin + Vector3(0,1,0)
		throw_object = item
		throw_origin = item.global_transform.origin
		throw_object.rotation_degrees = Vector3(randf() * 360, randf() * 360, randf() * 360)
		$Tween.interpolate_method(self, "set_position_throw_object", 0.0, 1.0, 1.3)
		$Tween.interpolate_property(throw_object, "rotation_degrees:y", throw_object.rotation_degrees.y, throw_object.rotation_degrees.y + 60 + randf() * 30, 1.3)
		$Tween.start()
		yield($Tween,"tween_all_completed")
		$RefuelSound.play()
		item.burn_effect()
		throw_object.queue_free()


func scare_enemy(enemy: Node):
	var state_mac_node := enemy.get_node("EnemyStateMachine")
	var state_machine: EnemyStateMachine
	
	if state_mac_node != null:
		state_machine = state_mac_node as EnemyStateMachine
		if state_machine == null:
			printerr("Fire spotted an enemy without proper EnemyStateMachine (Fire::scare_enemy())")
		var dir: Vector3 = self.global_transform.origin.direction_to(enemy.global_transform.origin)
		state_machine.get_node("RunAway").run_direction = Vector2(dir.x, dir.z)
		state_machine.transition_deferred("RunAway")
	else:
		printerr("Fire spotted an enemy without proper EnemyStateMachine (Fire::scare_enemy())")
	


var throw_object: Spatial
var throw_origin: Vector3
func set_position_throw_object(value):
	throw_object.global_transform.origin = get_throw_curve_position(throw_origin, 1.0, value)


func get_throw_curve_position(origin, height, value):
	var destination = global_transform.origin
	var diff = destination - origin
	return origin + value * diff + Vector3(0, height, 0) * throw_curve.interpolate(value)


func _on_ScareEnemyArea_area_entered(area: Area) -> void:
	scare_enemy(area.get_parent())
	

func _process(delta: float) -> void:
	# Maybe change it less often if it becomes a problem (but it shouldn't)
	var random = randf()
	var time = OS.get_ticks_msec()

	if random < flicker_chance * delta:
		# trigger a flicker
		if not currently_flickering and omnilight_base > 0.03:
			currently_flickering = true
			flicker_start_time = OS.get_ticks_msec()

	if currently_flickering:
		$OmniLight.light_energy = min_energy + (omnilight_base - min_energy) * flicker_curve.interpolate(time/flicker_length)
		
		if time > flicker_start_time + flicker_length:
			currently_flickering = false
	else:
		# have brightness follow a basic sine curve
		if omnilight_base > 0.03:  # else the fire is turned off
			var val = omnilight_base +  natural_variation * sin((time * 2 * PI)/1600)
			$OmniLight.light_energy = val * 10 
			$OmniLight.omni_range = val * 16 + 6
		else:
			$OmniLight.light_energy = 0.0
		

	


	
	
