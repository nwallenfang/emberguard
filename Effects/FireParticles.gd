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
	if p <= 0.0:
		$FireParticles.emitting = false
		$SparksSmall.emitting = false
	elif not $FireParticles.emitting:
		$FireParticles.emitting = true
		$SparksSmall.emitting = true
	#$FireParticles.amount = int(32 * p) + 4

func _process(_delta):
	$FireParticles.material_override.set("shader_param/world_pos", global_transform.origin)
