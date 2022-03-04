extends Spatial

onready var path_follow: PathFollow = $WagonPath/PathFollow

var wagon_speed: float = 2.5  # meter/s like a true physician
func start_wagon_path():
	pass



func _ready() -> void:
	# prepare path_follow to always be on the ground plane
	# so change the y coordinate of each point
	# TODO
	pass
#	var duration = $WagonPath.curve.get_baked_length() / wagon_speed
#	print("dur", duration)
#	$Tween.interpolate_property(path_follow, "offset", 0.0, $WagonPath.curve.get_baked_length(), duration)
#	$Tween.start()
#	$WagonPath/PathFollow.
