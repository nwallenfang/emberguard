extends Spatial

func _ready() -> void:
	$WeaponItem.connect("weapon_grabbed", self, "weapon_grabbed")
	

# maybe have this for every weapon spot once one weapon has been grabbed
# but it's not that important
func weapon_grabbed():
	$TreasureSimulation.emitting = false
	$SpotLight.visible = false
	
