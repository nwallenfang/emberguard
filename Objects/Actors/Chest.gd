tool
extends Spatial

export var open_percent := 0.0 setget set_open_percent

func set_open_percent(p):
	open_percent = p
	$Top.rotation_degrees.z = p * 180
