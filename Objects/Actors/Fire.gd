extends Spatial

export var fire_percent : float = 1.0 setget set_fire_percent

func _ready():
	set_fire_percent(fire_percent)

func set_fire_percent(value):
	fire_percent = value
	$Placeholder.scale.y = value
	$Placeholder.translation.y = .4 * value
