extends Spatial

export var fire_percent : float = 1.0 setget set_fire_percent
export(Curve) var throw_curve: Curve

func _ready():
	set_fire_percent(fire_percent)

func set_fire_percent(value):
	fire_percent = value
	$Placeholder.scale.y = value
	$Placeholder.translation.y = .4 * value

func interact():
	if Game.player.item_holded_count > 0:
		var item = Game.player.make_item() as Spatial
		Game.player.loose_item()
		item.global_transform.origin = Game.player.global_transform.origin + Vector3(0,1,0)
		throw_object = item
		throw_origin = item.global_transform.origin
		$Tween.interpolate_method(self, "set_position_throw_object", 0.0, 1.0, 1.3)
		$Tween.interpolate_property(throw_object, "rotation_degrees:y", 0, 90, 1.3)
		$Tween.start()
		yield($Tween,"tween_all_completed")
		throw_object.queue_free()

var throw_object: Spatial
var throw_origin: Vector3
func set_position_throw_object(value):
	throw_object.global_transform.origin = get_throw_curve_position(throw_origin, 1.0, value)

func get_throw_curve_position(origin, height, value):
	var destination = global_transform.origin
	var diff = destination - origin
	return origin + value * diff + Vector3(0, height, 0) * throw_curve.interpolate(value)
