extends Spatial


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass 

func set_fire_percent(p):
	$FireParticles.process_material.scale = p * .8 + .3
	$FireParticles.process_material.initial_velocity = p * .8 + .3
	if p == 0:
		$FireParticles.amount = 0
	elif $FireParticles.amount == 0:
		$FireParticles.amount = 32
	#$FireParticles.amount = int(32 * p) + 4
